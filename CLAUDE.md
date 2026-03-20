# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ODDB.org is the Open Drug Database for Switzerland (live at http://ch.oddb.org). It's a Ruby web application for searching and comparing pharmaceutical products, importing data from Swiss authorities (Swissmedic, BSV), and serving drug information (FachInfo, PatInfo).

## Build & Run Commands

```bash
# Install dependencies
bundle install

# Run full test suite (CI uses this)
bundle exec ruby test/suite.rb

# Run composition parsing specs
bundle exec rspec spec/parslet_spec.rb

# Run a single test file
bundle exec ruby test/test_model/test_package.rb

# Run full GUI integration specs (requires browser)
bundle exec rspec spec

# Lint with StandardRB (Ruby style checker)
bundle exec standardrb
bundle exec standardrb --fix  # auto-fix

# Reparse FachInfo/PatInfo text for a specific IKSNR
bundle exec ruby jobs/update_textinfo_swissmedicinfo --skip --target=both 62822 --reparse

# Start the app via Rack (port 8012 by default)
bundle exec rackup

# Generate documentation
rake docs
```

Ruby 3.4 is required.

- **Linux**: `sudo apt-get install libmagickcore-dev graphicsmagick uuid-dev libpq-dev`
- **macOS**: `brew install libpq graphicsmagick ossp-uuid` and `bundle config build.pg --with-pg-config=$(brew --prefix libpq)/bin/pg_config`

The codebase is cross-platform (Linux and macOS). System-level calls (e.g. memory/process stats via `/proc/`) have macOS fallbacks using `vm_stat`/`ps`.

## Architecture

### Framework Stack

- **SBSM** (State-Based State Machine) — web framework, not Rails. Request routing is done via state classes, not routes files.
- **HTMLGrid** — component-based view rendering (not ERB/Haml templates).
- **ODBA** (Object Database Abstraction) — ORM layer over PostgreSQL (`ch_oddb` database). Objects persist via `include Persistence` and methods like `odba_isolated_store`.

### Source Layout (`src/`)

| Directory | Role |
|-----------|------|
| `model/` | Domain objects (Package, Substance, Registration, Sequence, Composition, etc.) persisted via ODBA |
| `state/` | Controllers — SBSM state classes that handle requests. `state/global.rb` is the root dispatcher (~41KB) |
| `view/` | HTMLGrid view components (216 files). Render methods return HTML. |
| `command/` | Command pattern classes for mutations (create, delete, merge) |
| `custom/` | `LookandfeelBase` — UI theming and i18n dictionaries (DE, FR, IT) |
| `util/` | Core utilities: `oddbapp.rb` (main app/data store), `rack_interface.rb`, `session.rb`, `persistence.rb`, `updater.rb`, `exporter.rb` |
| `plugin/` | Extensible plugins including `parslet_compositions.rb` (Parslet-based drug composition parser) |
| `remote/` | Remote service integration (MIGEL) |

### Multi-Service Architecture

The app runs alongside several daemons (in `ext/`): export, meddata, refdata, swissindex, fiparse, swissreg. External services: Yus (auth, port 9997), MIGEL (port 33000). The main app listens on port 10000.

**Important:** The `fiparse` daemon (DRb on port 10002) runs as a separate process managed by daemontools (`/etc/service/fiparse`). Code changes to `ext/fiparse/src/` require restarting this daemon with `sudo svc -h /etc/service/fiparse` (HUP signal) for changes to take effect. The main app calls `@parser.parse_fachinfo_html(...)` via DRb, so the fiparse daemon must be running with the current code.

### Key Entry Points

- `config.ru` — Rack startup, creates `ODDB::App` via `ODDB::Util::RackInterface`
- `src/util/oddbapp.rb` — `OddbPrevalence` is the main data store (DDD aggregate root)
- `src/state/global.rb` — Root state dispatcher, routes all requests to sub-states
- `jobs/` — Import/export scripts (import_swissmedic_only, import_bsv, import_daily, export_csv, etc.)

### Testing

- **Minitest + FlexMock** for unit tests in `test/` (mirrors `src/` structure: `test_model/`, `test_state/`, `test_view/`, etc.)
- **RSpec + Watir** for browser integration tests in `spec/`
- `test/suite.rb` orchestrates all unit test suites via `OddbTestRunner`, running some tests in isolated subprocesses
- `test/test_helpers.rb` provides test utilities, fixtures, and GTIN data
- `test/stub/` contains ODBA mocks and other test doubles
- Tests run with `ENV["TZ"] = "UTC"` forced in `test/helpers.rb`
- Some test files must run in isolated subprocesses (defined as `must_be_run_separately` in each suite.rb) due to global state conflicts

### Drug Search Result List

- Result list columns are defined in `result_list_components` in `src/custom/lookandfeelbase.rb` (default) and overridden per flavor in `src/custom/lookandfeelwrapper.rb`.
- CSS for result list columns is in `CSS_KEYMAP` / `CSS_HEAD_KEYMAP` in `src/view/drugs/resultlist.rb`.
- Twitter share and mail/notify icons have been removed from all result lists.

### Swiyu Login & Query Limit

- Anonymous users are limited to 5 searches per 24h (`QUERY_LIMIT` in `src/util/session.rb`). After exceeding the limit, the user sees a login prompt.
- Swiyu login is handled by `SwiyuMiddleware` (`src/util/swiyu_middleware.rb`) which serves `doc/resources/swiyu/login.html` and manages auth via an in-memory store keyed by `_session_id` cookie.
- After login, the user is redirected back to their last search via a `return_url` query parameter passed through the Swiyu flow. Key files: `src/view/limit.rb`, `src/view/navigation.rb`, `doc/resources/swiyu/login.html`.
- The IP's query limit counter is reset on Swiyu login (`active_state` in `src/util/session.rb`).

### BSV FHIR Import (`jobs/import_bsv_fhir`)

- Imports SL (Spezialitätenliste) data from FHIR NDJSON exports downloaded from `epl.bag.admin.ch`
- Core implementation in `src/plugin/bsv_fhir.rb` (`BsvFhirPlugin`)
- FHIR data follows the [ch-epl IG](https://fhir.ch/ig/ch-epl/index.html). As of Feb 2026, `productPrice` and `costShare` are nested inside the `reimbursementSL` extension on `RegulatedAuthorization` (type code `756000002003`). The `extract_prices` method navigates: `RegulatedAuthorization.extension[reimbursementSL].extension[productPrice]`.
- Price type codes: `756002005001` = public (retail), `756002005002` = ex-factory
- NDJSON files are stored in `data/ndjson/`

### SDIF Drug Interactions

- Drug interaction checking uses the **SDIF** (Swiss Drug Interactions Finder) SQLite database at `data/sqlite/interactions.db`
- Core model: `src/model/sdif_interaction.rb` (module `ODDB::EphaInteractions` — name kept for backward compatibility)
- **DB tables**: `epha_interactions` (curated ATC-to-ATC, 15k+ pairs), `interactions` (substance-level from FachInfo), `drugs` (brand/ATC/substances/interactions_text), `class_keywords` (ATC prefix keywords), `cyp_rules` (CYP enzyme rules)
- **Four lookup strategies** (in priority order):
  1. **EPha curated** (label: "Quelle: EPha.ch"): Direct ATC-to-ATC lookup in `epha_interactions` table — risk_class (A/B/C/D/X), effect, mechanism, measures. Table only present if SDIF was built with `--epha` flag; gracefully skipped otherwise.
  2. **Substance-level** (label: "Quelle: Swissmedic FI"): Look up SDIF substance names via ATC code (`sdif_substances_for_atc`), query `interactions` table for direct matches
  3. **ATC class-level** (label: "Quelle: Swissmedic FI"): Load drug's `interactions_text` from `drugs` table, search for keywords from `class_keywords` table matching other drug's ATC prefix, extract sentence context, score severity
  4. **CYP enzyme-mediated** (label: "Quelle: Swissmedic FI"): Load `cyp_rules` table, check if one drug's FI text mentions a CYP enzyme and the other drug is a known inhibitor/inducer by ATC prefix or substance name. Covers CYP3A4, CYP2D6, CYP2C9, CYP2C19, CYP1A2, CYP2C8, CYP2B6.
- **Route indicators**: Purple badges showing administration route (topisch, i.v., p.o., s.c., inhalativ, nasal, ophthalm., etc.) next to drug names in interaction headers, read from the `route` column in the `drugs` table
- **Combo hints**: Green badges showing approved combination therapy hints (e.g. "Zugelassene Kombitherapie mit ASS") from the `combo_hint` column in the `drugs` table
- **Gegenrichtung hints**: Compares each interaction's severity against the maximum severity across all interaction types for the same drug pair (both directions). FI results (class-level, substance, CYP) show "Gegenrichtung hat höhere Einstufung" when their severity is lower than the pair maximum. EPha results show the hint only when the EPha severity itself differs between directions (asymmetric EPha rating). The pair-max includes EPha, class-level, CYP, and reverse-direction severities.
- **Severity scoring**: Keyword-based, synced with SDIF: 3=Kontraindiziert, 2=Schwerwiegend (toxizität, hyperkaliämie, etc.), 1=Vorsicht (erhöh-stem, plasmakonzentration, etc.), 0=Keine Einstufung. Tiermodell/Tierstudie/Tierversuch mentions are deprioritized in context extraction to avoid false snippet attribution.
- **Autocomplete**: Vanilla JS with fetch() to `/ajax_matches` endpoint, 200ms debounce, custom dropdown. Uses inline `onkeydown` attribute for keyboard handling (Enter key must be caught before browser form submission). Dojo toolkit replaced with minimal shim at `doc/resources/dojo/dojo/dojo.js`.
- Key files: `src/view/searchbar.rb` (autocomplete), `src/view/interactions/interaction_chooser.rb` (form), `src/plugin/epha_interactions.rb` (DB update plugin)

### Troubleshooting

- **Fachinfo table formatting**: Tables from swissmedicinfo with percentage-width styles (e.g. `width:100%`, `width:99.1800%`) are rendered as preformatted column-aligned text. The `detect_table?` method in `ext/fiparse/src/textinfo_html_parser.rb` controls this. Tables rendered as HTML tables use `colspan`/`rowspan` attributes from the source HTML; these default to `1` when not specified (cells without explicit attributes must not get `0`). The view (`src/view/chapter.rb`) only emits `colspan`/`rowspan` when > 1. After fixing table parsing, restart fiparse (`sudo svc -h /etc/service/fiparse`) and reparse: `bundle exec ruby jobs/update_textinfo_swissmedicinfo --skip --target=both <IKSNR> --reparse`

- **Corrupted ODBA search index**: If searches crash with `NoMethodError: undefined method 'fetch_ids'` on a non-index object (e.g. `PatinfoDocument`), the ODBA index is corrupted. The app will display an error page telling you which index to rebuild. Fix with:
  ```bash
  bundle exec ruby jobs/rebuild_indices <index_name>
  ```
  For example: `bundle exec ruby jobs/rebuild_indices sequence_index`

### Configuration

- `etc/oddb.yml` — primary app config (loaded via RCLConf)
- `etc/db_connection.rb` — PostgreSQL connection setup
- `etc/index_definitions.yaml` — ODBA index definitions
- `etc/barcode_to_text_info.yml` — barcode mappings

### Module Namespace

Everything lives under the `ODDB` module. Source files use `$LOAD_PATH` rooted at `src/`, so requires look like `require 'model/package'` not `require 'src/model/package'`.
