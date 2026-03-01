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

Ruby 3.4 is required. System dependencies: `libmagickcore-dev`, `graphicsmagick`, `uuid-dev`.

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

**Important:** The `fiparse` daemon (DRb on port 10002) runs as a separate process managed by daemontools (`/etc/service/fiparse`). Code changes to `ext/fiparse/src/` require restarting this daemon to take effect. The main app calls `@parser.parse_fachinfo_html(...)` via DRb, so the fiparse daemon must be running with the current code.

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

### Troubleshooting

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
