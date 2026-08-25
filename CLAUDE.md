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
- `SwiyuClient` (`src/util/swiyu_client.rb`) talks to the verifier at `https://swiyu.ywesee.com/verifier-mgmt/api`. That server lives in a separate repo (`swiyu4health`, host 212.51.146.241); ch.oddb.org is authorised there by IP whitelist, not by API key.
- **The verifier (4.x) accepts only DCQL.** Sending `presentation_definition` fails with `{"error_description":"dcqlQuery: must not be null"}`. The request body therefore uses `dcql_query` with `response_mode: "direct_post.jwt"` — swiyu wallet 1.17 enforces payload encryption during presentations, so a plain `direct_post` is refused with `invalid_request` before the wallet ever posts. The `CREDENTIAL_FORMAT` constant selects the media type (`vc+sd-jwt`, matching what the issuer emits — `dc+sd-jwt` is the newer canonical name and also accepted).
- `accepted_issuer_did` in `etc/swiyu_roles.yml` must match the issuer DID actually running on swiyu.ywesee.com. A mismatch surfaces only as a failed verification, never as a config error.
- The verifier returns the presented claims grouped by DCQL query id and wrapped in an array: `wallet_response.credential_subject_data` is `{"doctor_credential": [{...}]}`, not the flat claims hash the `presentation_definition` flow used to produce. `SwiyuMiddleware#extract_claims` unwraps both shapes; the key is `SwiyuClient::DCQL_CREDENTIAL_ID`.
- Debugging: the wallet reports every rejected authorization request as a bare `invalid_request` and then stops contacting the server. The evidence lives on the verifier host — `/var/log/apache2/swiyu-access.log` and the `management` table of `swiyu-verifier-db`. A `GET …/request-object/<id>` with no following `POST …/response-data` means the wallet rejected the request object itself, so the fault is on the verifier side, not in the credential.

### BSV FHIR Import (`jobs/import_bsv_fhir`)

- **Default source (June 2026):** `jobs/import_bsv` now runs the FHIR NDJSON import (`update_bsv_fhir`) by default, mirroring oddb2xml. Pass `--no-fhir` to fall back to the legacy XML (`XMLPublications.zip` / `update_bsv`) path. `jobs/import_bsv_fhir` remains as an explicit FHIR alias; `jobs/import_bsv_only` is the legacy XML-only job. Limitation flags and limitation texts (incl. FR/IT translations) are imported the same way as the XML path.
- Imports SL (Spezialitätenliste) data from FHIR NDJSON exports downloaded from `epl.bag.admin.ch`
- Core implementation in `src/plugin/bsv_fhir.rb` (`BsvFhirPlugin`)
- FHIR data follows the [ch-epl IG](https://fhir.ch/ig/ch-epl/index.html). As of Feb 2026, `productPrice` and `costShare` are nested inside the `reimbursementSL` extension on `RegulatedAuthorization` (type code `756000002003`). The `extract_prices` method navigates: `RegulatedAuthorization.extension[reimbursementSL].extension[productPrice]`.
- Price type codes: `756002005001` = public (retail), `756002005002` = ex-factory
- **Per-language NDJSON** (April 2026): downloads three files directly from `epl.bag.admin.ch/static/fhir/foph-sl-export-latest-{de,fr,it}.ndjson`. Each file contains a single language of free-text content (limitation texts, descriptions). The de file is processed as primary; fr/it files are pre-loaded into a SwissmedicNo8-keyed index so `merge_translation_names` and `merge_translation_limitations` can populate FR/IT translations per pack. SwissmedicNo8 is used as the lookup key (not iksnr) because a single iksnr can span many bundles (one per dose variant).
- Swissmedic category codes: `756005022001`=A, `756005022003`=B, `756005022008`=D
- NDJSON files are stored in `data/ndjson/`
- **Change detection via dated link** (June 2026): BAG publishes immutable dated snapshots `foph-sl-export-<YYYYMMDD>-{de,fr,it}.ndjson` alongside the moving `-latest-{lang}` alias; the two are byte-identical and the date in the link equals the `-latest-` file's `Last-Modified` date. `download_ndjson` issues a cheap HTTP **HEAD** on the `-latest-` file (no 90+ MB body), derives the dated link from `Last-Modified`, and persists it in a `<file>.source` sidecar next to the cached NDJSON. While the saved dated link matches the current one (and the cached file exists) the download is **skipped entirely** — no fetch, no reparse. The full file is (re)downloaded and reparsed only when the date moves. It downloads the immutable dated URL (race-safe vs. `-latest-` rotating mid-run) and falls back to `-latest-` if the dated file is not published yet, or to the old byte-comparison if the HEAD fails. Per-language gating means a language whose new dated export is not yet published (publication is sequential de→fr→it) simply lags one run instead of fetching stale content. Markers live at `data/ndjson/foph-sl-export-latest-{de,fr,it}.ndjson.source`.
- **Limitations live in `ClinicalUseDefinition`** (August 2026 fix): a limitation sits at `RegulatedAuthorization.indication[].extension[regulatedAuthorization-limitation]` with the sub-extensions `status`, `statusDate`, `period`, `firstLimitationDate`, `indicationCode` (the "IndC" code, e.g. `22064.07`, present on only ~37% of limitations) and `limitationIndication`. Until 2026 the text itself was inlined as a **`limitationText`** sub-extension; BAG moved it into a separate **`ClinicalUseDefinition`** resource that `limitationIndication` references, and `limitationText` no longer occurs in the export **at all**. `extract_limitation_data` skipped every limitation without it, so the import silently stopped delivering limitation texts (only 16 legacy texts left in the DB against ~6300 in the export). It now follows the reference via `limitation_text_from_reference`, reading `indication.diseaseSymptomProcedure.concept.text` (plain text; falls back to the `text.div` narrative). The referenced resource **always travels in the same bundle**, so `resources["ClinicalUseDefinition"]` is passed in; the FR/IT bundles carry the same ids with translated text, which is what makes `merge_translation_limitations` work. The resource **id is the LimitationCode** (e.g. `ABEVMY.07`) — limitation-specific, stable across publications and truncated to 64 chars for FHIR without collisions (per BAG/EPL, 03.08.2026); see GitHub issue #443. `indicationCode` is written to the section subheading, and `View::Chapter` renders subheadings, so the IndC code shows up on the limitation-text page automatically. Regression tests: `test/test_plugin/bsv_fhir.rb`.
- **The export moved (August 2026)**: `https://epl.bag.admin.ch/static/fhir/foph-sl-export-*` became `https://epl.bag.admin.ch/static/sl/publication/fhir/foph-sl-publication-*` (`FHIR_BASE_URL`, `FHIR_FILE_PREFIX`). The **old `-latest-` alias answers 404** while the old dated snapshots stay in place, so `download_ndjson` found nothing and `update` returned nil — and `import_bsv` **reported exit 0 every morning while importing nothing**, from 14.08.2026 until it was noticed. A job that is silent about doing nothing is the thing to distrust here; the give-away was `bsv_fhir: HTTP 404 for ...` three times in `log/cron/import_bsv-2026-08.log` followed by `return_value_BsvFhirPlugin.update = nil`. A `-latest-` alias exists again at the new location.
- **Do not depend on `-latest-` alone.** It has vanished once, so `newest_dated_url` walks back from today (`DATED_LOOKBACK_DAYS`, 45) and takes the first dated file that answers, stopping at the date in the `.source` marker — nothing newer than what is held means nothing to do. `-latest-` is still tried first, so a normal day costs one HEAD and no searching. Regression tests: `test/test_plugin/bsv_fhir.rb`, `TestBsvFhirPluginDatedUrl`.
- **BAG publishes SL data monthly, on the 1st** (off-cycle only to correct something); Swissmedic publishes in the first week of the month. A run that reports "no change" is therefore the expected result on 28 of 30 days and no cause for alarm — but no change *on the 1st* is the alarm.
- **Ghost packs (August 2026)**: the export lists some packs **twice under one Swissmedic number** - once with a GTIN and the pack price, once without a GTIN, described "1 Stk", carrying the price *per unit*. Both resolve to the same package via `package_by_ikskey`, both prices are written, and whichever came last survives. Enflonsia stood at 354.60 instead of 3545.85, Menveo at 37.75 instead of 188.75. `ghost_pack?` drops a GTIN-less pack **only when another pack with a GTIN shares its number** - a blanket filter would lose the 49 packs (of 55 without GTIN, out of 10255) that legitimately have none and are the only pack under their number. `jobs/repair_ghost_pack_prices <gtin>=<preis> --apply` repairs what is stored; the filter only prevents recurrence. Issue #445, reported to BAG.
- **To answer "is a price wrong", measure the lot**: parse GTIN → retail price out of the NDJSON, walk every package, compare. 10010 of 10013 matched. A hand-picked example proves nothing, and the flapping ones (`set price_public A -> B` then `B -> A` in the log) are the tell.
- **SL-introduction / price change flags** (July 2026 fix): the med-drugs xls export (`OuwerkerkPlugin`, sent to `med-drugs@just-medical.com`) reads the `:bsv_sl` log group's `change_flags`. The FHIR plugin's `fix_flags_with_rss_logic_for` is the **sole** source of the `:sl_entry` (new Kassenzulässigkeit → xls flag 10), `:price_cut` (15) and `:price_rise` (13) flags — unlike the XML plugin it has no `StatusTypeCodeSl == "2"` (Neuaufnahme) driver. That method runs **after** `pack.price_public = price_public` has already unshifted the new price to index 0, so it must read the previous price from history via `pack.price_public(1)` (mirroring `src/plugin/rss.rb`); reading `pack.price_public(0)` returns the freshly-stored price and silently drops all three flags, so the med-drugs file lists no SL introductions even though `sl_introduction.rss` (which recomputes from price history) still does. Flags are only recomputed when the NDJSON actually changes (`update` runs `_update` `if changed`), so a fix takes effect on the next fresh BAG export, not on a no-change re-run. Regression test: `test/test_plugin/bsv_fhir.rb`.

### Med-Drugs XLS Export (`export_ouwerkerk`)

- `OuwerkerkPlugin` builds the monthly med-drugs xls sent to `med-drugs@just-medical.com` via the `ouwerkerk` mailing list. It runs as a **follower of `jobs/import_bsv`** (`Updater#update_bsv_followers`), not as a job of its own.
- It combines **two** log groups: registration-level flags from `:swissmedic` (`:new` → xls flag 1, `:name_base` 3, `:composition` 6, `:sequence` 8, `:expiry_date` 9, `:delete` 14 …) and package-level flags from `:bsv_sl` (`:sl_entry` 10, `:price_rise` 13, `:price_cut` 15, `:sl_entry_delete` 2). Both come from `log_group(...).latest`, so the mail subject reads e.g. "Swissmedic 06/2026 - SL 08/2026" — the two halves are normally from different months.
- **Flags not present in `NUMERIC_FLAGS` are dropped silently** (`rows.delete_if { … row.first.empty? }`). `:size`, `:substances`, `:atc_class`, `:ikscd` etc. have no numeric equivalent, so a diff consisting only of such flags yields an **empty export**.
- **`:swissmedic` log month**: `update_swissmedic` writes to `@@today << 1` (a July run fills the *June* log), whereas the BSV path writes the current month.
- **change_flags are merged, not overwritten** (August 2026 fix): a monthly log is written once per import run and each run only reports what changed **since the previous download**, so a later run in the same month must not discard what an earlier run recorded. `Updater#merge_previous_change_flags` (shared by `update_swissmedic` and `log_notify_bsv`) merges the stored flags into the new ones. Without it this happened: Swissmedic published a **corrupt Packungen file on 2026-07-04** (wrong `Packungsgrösse` on ~3200 packages) and republished it corrected on **2026-07-08**; the 07-08 run diffed correct-against-corrupt, produced a `:size`-only mass diff of 1182 registrations and **overwrote** the 27 `:new` registrations the 07-04 run had recorded — so the August med-drugs file contained no Neuregistrierungen at all (Aug 1 was 0 rows). `SwissmedicPlugin#warn_if_degenerate_diff` now logs a `SwissmedicDiff SUSPECT` warning when a large share of changed registrations carry a single flag only, which is the signature of a corrupt file on one side of the comparison. Regression tests: `test/test_util/updater.rb`.
- To recompute a Swissmedic diff **without touching the DB**, include `SwissmedicDiff::Diff` in a bare class and call `diff(new_xlsx, old_xlsx, [:sequence_date])` — it is pure file-to-file; the DB mutation lives in the plugin's `update_registrations`/`delete`/`deactivate` calls. Snapshots are kept as `data/xls/Packungen-<YYYY.MM.DD>.xlsx`.

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

- **Stale PostgreSQL connections**: If pages crash with `DBI::ProgrammingError: PQsocket() can't get socket descriptor`, the ODBA connection pool holds dead connections (typically after a PostgreSQL restart or idle timeout). The monkey-patch in `src/util/odba_connection_patch.rb` automatically reconnects on stale connections with up to 3 retries. If the issue persists, restart the app process.

- **Corrupted ODBA search index**: If searches crash with `NoMethodError: undefined method 'fetch_ids'` on a non-index object (e.g. `PatinfoDocument`), the ODBA index is corrupted. The app will display an error page telling you which index to rebuild. Fix with:
  ```bash
  bundle exec ruby jobs/rebuild_indices <index_name>
  ```
  For example: `bundle exec ruby jobs/rebuild_indices sequence_index`

### Drug Shortage Import (`jobs/update_drugshortage`)

- Imports current Swiss drug shortages from drugshortage.ch into the `shortage_*` fields on `Package` objects (`shortage_state`, `shortage_last_update`, `shortage_delivery_date`, `shortage_link`)
- Core implementation in `src/plugin/shortage.rb` (`ShortagePlugin`)
- **May 2026 migration**: drugshortage.ch retired its ASP.NET `UebersichtaktuelleLieferengpaesse2.aspx` page (now returns HTTP 500) and switched to a WordPress site with JSON APIs. The plugin fetches `https://www.drugshortage.ch/api/api_engpaesse.php` — the official "show all current shortages" endpoint backing the `uebersicht-nach-firmen` page. Returns ~705 active shortages as JSON in a single call, under the top-level `engpaesse` key.
- **June 2026 endpoint move**: the endpoint moved from `/api_engpaesse.php` to `/api/api_engpaesse.php`. At the same time `status` values gained a leading category-number prefix (e.g. `"1 aktuell keine Lieferungen"` instead of `"aktuell keine Lieferungen"`). The plugin strips the leading `\d+\s+` from `status` before assigning `shortage_state`, so existing DB values stay stable and the migration email stays quiet on field churn. The leading digit duplicates `bewertung` and is not needed.
- **June 2026 HMAC request signing**: later in June 2026 the API began rejecting unsigned requests with **HTTP 403** (`{"fehler":"Zugriff verweigert – fehlende Header"}`). Every call must now carry an HMAC-SHA256 signature plus the headers the server's CORS policy advertises (`X-Timestamp`, `X-Nonce`, `X-Signature`, `X-Requested-With`). The signature is `HMAC_SHA256(secret, "<timestamp>|<nonce>|<api_name>")` as lowercase hex, where `api_name` is `api_engpaesse` and the shared secret + scheme are taken verbatim from the site's inline signing JS (visible in the page source of `uebersicht-nach-firmen`; the same scheme also backs the newer `ds.php?a=…` endpoints). `ShortagePlugin#shortage_source_headers` generates a fresh timestamp+nonce per call (the server rejects stale/replayed requests) and these headers are passed through `Latest.get_latest_file` → `Latest.fetch_with_http` (`URI.open`). The URL, the `engpaesse` payload, and the field mapping are unchanged — only the headers were added. If this breaks again, re-read `HMAC_SECRET` and the `hmacSign()` message format from the page source.
- JSON field mapping: `gtin` → `gtin`, `mutation` (DD.MM.YYYY) → `shortage_last_update`, `status` (stripped of `"<digit> "` prefix) → `shortage_state`, `lieferdatum` → `shortage_delivery_date`, `id` → used to construct `shortage_link`.
- **`shortage_link`** is constructed as `https://www.drugshortage.ch/index.php/detail-lieferengpass/?ID=<id>` where `<id>` is the stable upstream record id from `engpaesse[].id`. This is the new per-shortage detail page (replaces the old `detail_lieferengpass.aspx?ID=...`).
- Change-detection still uses `Latest.get_latest_file`'s byte-size comparison (`src/util/latest.rb`); fresh fetch is skipped if today's downloaded size matches the cached `data/json/drugshortage-latest.json`.

### Google Search Console Indexing Check (`jobs/check_indexing`)

- Verifies whether the pages behind a Search Console "Serverfehler (5xx)" report still fail for Google.
- **There is no API for the Page Indexing report.** `urlcrawlerrorssamples` was shut down in 2019 and never replaced; the API has only Search Analytics, Sitemaps, Sites and URL Inspection. The URL list must therefore come from our side.
- Candidates are read from `log/YYYY/MM/DD/oddb_log` (lines with status 500) by `IndexingCheck.failing_urls`, then looked up one by one via `POST https://searchconsole.googleapis.com/v1/urlInspection/index:inspect`.
- Response fields used: `pageFetchState` (`SERVER_ERROR`, `INTERNAL_CRAWL_ERROR`, `SOFT_404`, `REDIRECT_ERROR` count as still-failing; `SUCCESSFUL` is the goal), `verdict`, `lastCrawlTime`.
- **Quota**: 2000 inspections per property per day, 600/min. `--limit` caps the daily volume (default 200); `MIN_SECONDS_BETWEEN_CALLS` throttles the rate.
- **Auth**: service account, RS256 JWT signed with stdlib `openssl` and traded for an access token — deliberately no `googleauth`/`signet`/`google-apis-*` dependency. Key path in `gsc_service_account_json` (`etc/oddb.yml`, gitignored). The account's `client_email` must be a **Full** user of the property; Restricted is not enough.
- **Property resolution**: `gsc_site_urls` maps domain → property. `IndexingCheck.site_url_for` matches the exact host first, then strips labels from the left, because a `sc-domain:` property covers its subdomains (`sc-domain:oddb.org` serves `ch.oddb.org`, `i.ch.oddb.org`, `oekk.oddb.org`). Hosts with no property — including malformed ones crawlers send, e.g. `chahmer.ch` or `.oddb.org` — are skipped without spending quota.
- **Properties can be created entirely through the API**, contrary to Google's own documentation, which says verification needs user authentication and that service accounts cannot do it. The blocker was only that `siteverification.googleapis.com` was not enabled in the project; with it on, the service-account JWT is accepted. Two calls: `POST /siteVerification/v1/token` returns the token, then `POST /siteVerification/v1/webResource?verificationMethod=FILE|DNS_TXT` verifies. `webmasters/v3/sites` then registers it — that one needs the writable `webmasters` scope, not `webmasters.readonly`. Adding a human as owner is a `PUT` on the webResource with the address appended to `owners`.
- **FILE vs DNS**: `generika.cc` was verified with FILE (`doc/googleae704f5f3e3a1945.html`) and needed no DNS access. `oddb.org` could not: the `:80` redirect answers 302 for every path except `/.well-known/`, so Google can never fetch a verification file there, and a URL-prefix property would cover only the apex, which now serves nothing but redirects. It went the DNS_TXT route, which also buys the subdomains.
- As of August 2026 the properties are `sc-domain:oddb.org`, `sc-domain:ch.oddb.org` and `https://generika.cc/`.
- Key files: `src/util/google_search_console.rb` (API client), `src/util/indexing_check.rb` (log parsing + report), `jobs/check_indexing`. Tests: `test/test_util/indexing_check.rb`.
- **Watch the routing**, not just the code: Apache proxies UA `google` to **port 8112 (`google_crawler`)** and other bots to 8212 (`crawler`), via `RewriteCond %{HTTP_USER_AGENT}` in `etc/20_oddb.org.rack.conf`. In August 2026 three of the four rack backends were dead for days while `svstat` reported "up" (the PID did not exist), so those crawlers got a blanket 503 — a far bigger cause of 5xx reports than any application bug. Counting requests per day in `log/YYYY/MM/DD/<service>_log` is what makes it visible; zero is unmistakable:

  | service | port | dead from | back | duration |
  |---|---|---|---|---|
  | `crawler` | 8212 | 05.08. 08:33 | 23.08. 22:36 | 18.6 d |
  | `generika` | 8512 | 13.08. 22:23 | 24.08. 06:28 | 10.3 d |
  | `google_crawler` | 8112 | 14.08. 05:08 | 23.08. 22:38 | 9.7 d |

  `oddb_cron healthcheck` now watches the ports for exactly this (see Cron below). Check `ps -p <pid>` and not just `svstat`.

- **A Search Console mail names the property it came from**, and that is worth reading: the August one was about `http://www.generika.cc/`, a legacy URL-prefix property over http and www that the service account cannot see at all (`jobs/check_indexing --list-sites` lists only `sc-domain:oddb.org`, `sc-domain:ch.oddb.org`, `https://generika.cc/` and `https://adhs.expert/`). It kept reporting because its host answered **302**; a 302 tells Google the old URL is still a thing of its own. Those redirects are `permanent` now.

### The 500s Google reported as "Serverfehler (5xx)"

About 25000 in August 2026, on exactly the pages Google crawls. Four fixes, roughly 24500 of them:

- **`view/drugs/change_logs.rb` — 21960.** Every `/diff/` page. The strings a `ChangeLogItem` stores are clean UTF-8 (0 of 129042 are binary-tagged); the tag appears only while rendering. Diffy force-encodes the external `diff` output to ASCII-8BIT when it is not valid UTF-8 (ydiffy `diff.rb:60`), the html formatter then re-diffs character by character, and `String#split('')` on a binary string splits multi-byte sequences into single bytes. Those go into a Tempfile, and because `config.ru` sets `Encoding.default_internal = UTF-8` the write transcodes and raises. **Without `default_internal` the bug does not reproduce** — which is why it never showed up in tests. `View::Drugs.utf8_diff` re-tags and scrubs only the genuinely invalid bytes.
- **`view/drugs/patinfo.rb` — 1440, `model/fachinfo.rb` — 560.** Broken ODBA references: 253 of 48934 chapter stubs declare `Text::Chapter` while their `odba_id` holds a `PatinfoDocument`, and `Fachinfo` objects hold stubs to link objects that no longer exist. What made it fatal is that **`ODBA::Stub#is_a?` answers from the declared class without resolving the stub**, so `is_a? Text::Chapter` passed and the next call raised. `Stub#respond_to?` does resolve — the guards ask that now.
- **`display_names` / `PatinfoInnerComposite#init`.** `unless document&.empty?` lets a *nil* document through, because `PatinfoDocument#empty?` returns nil and so does `nil&.empty?`. Only visible after `patinfo_name` stopped raising first on the same pages — fixing one crash exposed the next.
- **`view/admin/sequence.rb` — four more sites**, found by replaying the urls Search Console still lists as 5xx: `substances` and `inactive_agents` got an Array where an `ActiveAgent` was declared, `active_agents` sorted by calling `.substance` on every element so one bad agent killed the page, and `ikscd` hit `nil.to_csv` (50 of the August 500s). Note how the guard is written: the obvious `sub.respond_to?(:de)` would reject **every real substance**, because `SimpleLanguage` defines no `de`/`fr`/`it` methods at all — it routes any two-letter symbol through `method_missing` and overrides `respond_to?` to match.
- **These failures are intermittent.** The same url answered 500 and then 200 minutes later with no restart, because whether a stub resolves depends on cache and connection state. Do not use a single url as proof that a fix worked; the tests exist for that.
- Regression tests: `test/test_view/drugs/change_logs.rb`, `test/test_view/drugs/patinfo.rb`, `test/test_model/fachinfo.rb`, `test/test_view/admin/sequence.rb`.

None of this repairs the underlying data; it stops one broken reference from taking a whole page down. And the biggest single cause was not code at all: three rack backends were dead for 9.7 to 18.6 days while `svstat` reported "up".

**Beware of measuring through `:443`.** Anubis answers `curl` with a 500 and an "Oh noes!" page while serving browsers normally, so a redirect chain tested with curl can look like it ends in a server error when it does not. Either send a Googlebot user-agent, which bypasses Anubis, or probe `http://localhost:8012` directly. This has now cost time twice.

### Orphaned change logs (`jobs/repair_orphaned_change_logs`)

- **A `change_log` hangs on the document, not on the drug.** `@change_log` is an ivar of `FachinfoDocument` / `PatinfoDocument` (`src/model/patinfo.rb:76-128`), and every FI/PI update creates a *new* document. `store_fachinfo` and `store_patinfo_change_log` carry the list over; where they don't, the whole history is cut loose at once. In August 2026 **31447 of 125403 change log items** were unreachable — a quarter of the diff history, over 3973 drugs, median 4 per drug and up to 140.
- **The drugs are all still there.** 0 of 15549 `Registration`, 0 of 24895 `Sequence`, 0 of 14548 `Patinfo` unreachable. What is orphaned are superseded *versions of the texts*. On a page it looks like a clean cut at a date: `/show/fachinfo/51886/diff` listed 7 revisions from 14.08.2017 on, and 61 from 15.11.2015 to 12.08.2017 lay unreachable beside them.
- **Every FI and PI carries its own registration number**, at the end of the text ("Zulassungsnummer 12345 (Swissmedic)"), and `Diffy::Diff` stores the complete old *and* new text — so an orphaned entry can be attributed from its own content. 29088 of 31447 yield a number that way. The same double storage is what makes the database 19 GB.
- **The verdict is a check against the target**, not the extraction: does the document's own text carry the same number? 20167 confirmed, 721 not — and those are typically neighbours like 59410 against 59411, the same substance in another strength, whose texts resemble each other. A regex alone would have attached them to the wrong drug.
- **Two steps, so what gets written is reviewable.** `--plan` writes `item, document, verdict`; `grep` filters; `--from-plan --apply` attaches exactly those pairs and decides nothing again. Appending only, never deleting, and every pair goes to a `.undo` file.
- **`odba_isolated_store` on a document does not write its `change_log`.** The list is a separate ODBA object with its own `odba_id` and is replaced by a stub in the document's dump (`odba_replace_persistables`), so it has to be stored itself, *before* the document. Getting this wrong yields a run that reports 20107 written and changes nothing — visible only by re-reading in a fresh process, never from the job's own success report.
- **The database already holds that mistake**: 7614 edges in `object_connection` point at an `odba_id` with no row in `object` — 4091 from `Package`, 1732 from `Hash`, 1120 from `SimpleLanguage::Descriptions` (the empty Patinfos), 272 from `FachinfoDocument2001`. Where a document's `change_log` stub dangles, reading it raises `ODBA::OdbaError` and the page is dead; the repair recreates the list, since nothing can be lost that was never written.
- **Verifying orphanhood needs two independent methods**, because a single one only proves the model. A recursive BFS over the 7373917 edges from the named, `prefetchable` and index-referenced roots, and a walk through all 14996 live registrations collecting every reachable change_log id. The 93946 the walk found and the 31447 the search called orphaned did not overlap in one single case. **Do not put `object_connection` in the root set** — it has a `target_id` column too, so an `information_schema` query picks it up and every object with any incoming edge becomes a root.
- Result: 20105 reattached, orphans down from 31447 to 11340. Still open: 2948 registrations with several distinct `Patinfo` objects (ambiguous, skipped), 2359 with no number in the text, 1289 with no target document left, 721 doubtful.
- **The cause is not established.** Three attempts failed: the `instance_of?` subclass bug in `fix_odba_error_in_patinfo` (`PatinfoDocument2001` exists 64 times in the whole database, so it cannot explain the mass), a January 2026 correlation with the deletion log (310 orphans over 144 drugs against 15 logged deletions), and an assumed pre-2018 lull that the complete inventory disproved. The loss runs continuously from 2015 (417) to 2025 (5386). A snapshot of every reachable change_log id per registration is in place to be compared after the next `update_today`.

### Dangling ODBA references (`jobs/repair_dangling_references`)

- **`checkout` deleted the child and kept the reference.** `Package#checkout` called `odba_delete` on `@sl_entry` and `@parts` and cleared neither, so the package held a stub to an object that no longer existed. **3950 packages** for `@sl_entry`, 141 for `@parts`. `Sequence`, `Registration` and `Composition` had the same shape (`@packages`, `@compositions`, `@sequences`, `@active_agents`). All four fixed August 2026; `delete_sl_entry` twenty lines below in `package.rb` had always done it right and is the model.
- **No `odba_isolated_store` in `checkout`.** It runs immediately before or after the `odba_delete` of the object itself (`util/persistence.rb:283-291`, `model/sequence.rb:124`), so storing would recreate what was just deleted. Clearing the ivar is the whole fix.
- **Why it stayed invisible for years:** only `limitation` and `limitation_text` go through `@sl_entry`. Price, deductible, generic type and name come from other fields, so the pages answered 200 and only the limitation was missing — 292 of 300 sampled packages raised `ODBA::OdbaError` on it. A 500 would have been found sooner.
- **Clearing, not restoring, is the right repair here**: of 3924 affected packages only **135** are still in the BAG NDJSON, the other 3789 have left the Spezialitätenliste. The reference was not just broken but moot, and a package that returns to the SL gets `@sl_entry` set again by the next BSV import.
- Result: 4410 objects cleaned, dangling edges 7502 → 3258, `limitation` answers on 300 of 300. Among them 257 `@connection_keys` on `Substance` — an ivar that appears nowhere in `src/`, `ext/` or the odba gem any more, a fossil.
- **Restricted to `ODDB::` classes.** The dangling edges also cover ODBA's own `@rebuilt`, `@failures`, `@to_drop`, `@deffered_indices` on index objects; those belong to `jobs/rebuild_indices`.
- **The 1120 `SimpleLanguage::Descriptions` are left alone** and that is deliberate: their broken links are hash entries rather than ivars, and `Text::Document` declares `@descriptions` as `ODBA_SERIALIZABLE` (`src/model/text.rb:613`), so the field is written inline and the separate objects are a fossil nobody follows. 6652 probes of `guidelines` / `ddd_guidelines` over all 8911 ATC classes raised nothing, and 120 ATC pages answered 200. **A dangling edge in `object_connection` is not proof of a broken page** — check whether the code still takes that path.
- Tests: `test/test_model/package.rb#test_checkout`, `test/test_model/composition.rb#test_checkout`. The composition one used to assert `checkout`'s return value, which happened to be `odba_delete`'s; it asserts the empty list now.

### Flavors

- Registered in `LookandfeelFactory::WRAPPERS` (`src/custom/lookandfeelfactory.rb`). Removing an entry retires a flavor: `SBSM::Session#flavor` validates against `LookandfeelFactory.include?` and falls back to `DEFAULT_FLAVOR` (`"gcc"`), so the URL keeps working and renders as gcc. The wrapper class, css theme and view branches stay in the tree — putting the entry back revives it.
- **`just-medical` retired August 2026**: `just-medical.oddb.org` is NXDOMAIN, the path flavor saw no traffic at all, and the partner's stylesheet only answers from `old.just-medical.ch`. Its `:80` vhost redirected to *itself* over https (a loop), its `:443` vhost proxied to `localhost:8312`, and its dedicated service is gone. **Unrelated to the med-drugs xls export**, which mails `med-drugs@just-medical.com` through the `ouwerkerk` list and never touched the look and feel.
- **`desitin` retired August 2026** on request. Unlike just-medical it was in use — 1206 requests from 459 distinct addresses across 21 of 24 days, on real content paths — so this was a decision, not a cleanup. Its `:80` and `:443` vhosts existed only in the repo copy, its four `epilepsie-*` aliases all answer SERVFAIL, and its certificate has been deleted.
- **`Session#flavor` has two paths** (`src/util/session.rb`). For `ch.oddb.org` it defers to SBSM, which validates. For every other host it resolves from the hostname or, failing that, the first path segment — and that branch used `[a-z]+`, which stops at a hyphen, so `/de/phyto-pharma/` yielded the flavor `phyto` and `/de/just-medical/` yielded `just`. Nothing validated it either, so `/de/nonsense/` yielded `nonsense`, and SBSM builds resource urls from the flavor: those requests asked for `/resources/nonsense/oddb.css`. Both fixed August 2026.

### Cron (`etc/crontab`, `bin/oddb_cron`)

- `/etc/crontab` and every script it calls are versioned. Install both with `sudo bin/install_crontab --apply`, which backs up what it replaces to `/var/backups/oddb-config/`. Never `cp` the crontab alone: it calls `/usr/local/sbin/oddb_cron`, which the install step puts there.
- **`bin/oddb_cron` holds everything** the crontab used to call as separate scripts — `job <name>`, `certbot-renew`, `backup` — plus `schedule`, the dispatcher, and `healthcheck`.
- **`healthcheck` watches the four rack ports** (8012, 8112, 8212, 8512), because `svstat` says "up" as long as `supervise` runs — whether or not the child exists or listens. That is how three backends stayed dead for 9.7 to 18.6 days in August 2026 with nobody noticing. It runs from the same once-a-minute `schedule` line, as zdavatz, so `/etc/crontab` needs no new entry and nothing new runs as root.
  - **Any HTTP status counts as alive.** A 500 from the application still proves the process is up; `curl` reports `000` on a refused connection, which is the state a missing backend leaves. HEAD, so a probe costs ~40 ms.
  - **The hard part is not acting.** These processes exit on purpose past `MEMORY_LIMIT_CRAWLER` (4000 MB, `src/util/oddbapp.rb`) and daemontools restarts them within a second, but they need ~40 s to answer again. Hence `HEALTH_GRACE=5` consecutive silent minutes before anything happens: TERM at 5 and 10, KILL from 15. A check that fired on the normal restart cycle would be worse than no check.
  - **`svstat` reporting "down" is left alone** — that means somebody ran `svc -d`, which is a decision.
  - **`svc` needs write access to `/etc/service/<name>/supervise`, not root**, and that ownership is unrelated to the user the service runs as: `crawler` and `google_crawler` run as root behind a zdavatz-owned supervise directory. `generika` was the exception — process as zdavatz, supervise as root, so `svstat` answered "access denied" and `svc` could not have restarted the one service that stayed dead longest. All four are zdavatz-owned since 24.08.2026. If a supervise directory ever reverts (supervise recreates missing files as root), `svc` fails there and the failure is logged rather than swallowed.
  - Tests: `sh test/test_bin/healthcheck.sh` (stubs `curl`, `svc`, `svstat`; not part of `test/suite.rb`, which is minitest against `src/`). State in `log/cron/health/<service>`, log in `log/cron/healthcheck-<YYYY-MM>.log`, and `--dry-run` prints the current state without touching anything.
- **One line for all nine jobs.** `* * * * * zdavatz /usr/local/sbin/oddb_cron schedule` runs every minute; the times live in the `SCHEDULE` table inside the script (`oddb_cron schedule-list` prints them). Costs ~10 ms per invocation and matches nothing on 1431 of the 1440 minutes. `certbot-renew` and `backup` stay separate lines because cron takes one user per line and those run as root.
- **Root-owned on purpose.** cron runs the certbot and backup lines as root, and this tree belongs to `zdavatz` — the user the web application runs as. A root cron line pointing into `/var/www` would turn a compromised application into root access. That was the pre-existing state: `/usr/local/sbin/ywesee-backup` is zdavatz-owned and cron ran it as root at 22:00. The old scripts stay on disk, dormant; edit `bin/oddb_cron`, not them.
- **Output is no longer discarded.** The old lines ended in `>/dev/null 2>&1`, so a failing import looked exactly like a successful one — which is how the med-drugs exports went wrong for two months unnoticed. Output goes to `log/cron/<job>-<YYYY-MM>.log` and the exit status reaches cron. In `cmd_schedule` the `SCHEDULE` table is read from a here-doc, not a pipe: a piped `while` runs in a subshell and would swallow a failing job's status.
- **`import_bsv` (08:00) and `import_swissmedic` (08:15) overlap deliberately.** Everything matching `^update|^import|^rebuild|^repair` shares `log/job.pid` (`Util::Job.run` checks with `Process.getpgid`), so the first to fire holds it and the second exits with a "Duplicate Job" notice. BSV publishes on the 1st of the month, Swissmedic somewhere in the first week; whichever wins gets the day and the other catches up next morning.
- Not absorbed: `pg_backup.sh` (carries the postgres password in clear text, like the gitignored `etc/db_connection.rb`), and the `sdif` / `swissmedicinfo` binaries, which live in their own repositories.

### Apache vhosts (`etc/20_oddb.org.rack.conf`)

- **The repo copy is not the live file.** Apache reads `/etc/apache2/sites-available/oddb-ssl.conf`; the two had drifted — the live one lacked the `desitin.oddb.org` vhosts the repo carried, which is why `https://desitin.oddb.org/` was served the `ch.oddb.org` certificate. Change both, or a change silently does nothing.
- **A catch-all `*:80` vhost must stay first.** Apache serves the first `*:80` vhost for any Host header matching no `ServerName`, and that used to be `sl_errors.oddb.org` — so `http://oddb.org/` and bot probes with mangled hosts (`chahmer.ch`, `.oddb.org`) got a directory listing of `doc/sl_errors`, including 4.3 GB of debug logs under `db/`. The catch-all exempts `/.well-known/` so an ACME challenge is never redirected.
- `doc/sl_errors` is the DocumentRoot of `sl_errors.oddb.org` and stays fully browsable: the `YYYY/MM` folders are the monthly SL error reports written by `Updater#update_bsv` and `BsvXmlPlugin` that BAG reads.
- **`Redirect /` appends the remaining path**, so a target without a trailing slash concatenates: `http://generika.cc/de/generika/` redirected to `https://generika.cc**de**/generika/`. Two shapes, two fixes — for a redirect to a landing page on another host use `RedirectMatch ^/(?!\.well-known/).*`, which appends nothing; for the same service under another name or scheme keep `Redirect` and put the slash on the target. **Classifying a host into the wrong shape is silent**: `anthroposophika.ch`, `xn--homopathika-tfb.ch`, `phyto-pharma.ch` and `phytotherapeutika.ch` point at *landing pages* but were given the trailing-slash form in August 2026, so `/de/generika/` landed on `/de/anthroposophy/home/de/generika/` — which answers 200, because SBSM ignores the tail, and is therefore easy to miss. Only the shape tells you; the status code does not.
- **A redirect-only host should be `permanent`.** `www.generika.cc` and `generika.oddb.org` answered 302 for years, which is why the legacy `http://www.generika.cc/` Search Console property kept crawling and reporting. Neither has a certificate and neither will ever serve anything of its own, so a permanent redirect forecloses nothing. Note that 301s are cached indefinitely by browsers — worth being sure before setting one.
- **The app-down page is per vhost.** `ErrorDocument 500/503` is what a visitor sees while a backend is unreachable, and it works because the `RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_URI} -f` rule serves existing files off disk before the proxy rules run. `ch.oddb.org` and `sl_errors.oddb.org` use the shared `doc/resources/errors/appdown.html`; `generika.cc` has its own `appdown_generika.html`, because the shared one is the oddb.org page down to the gcc logo, the gcc stylesheet and a PayPal form returning to `www.oddb.org`. The other app vhosts have no `ErrorDocument` at all and fall back to Apache's default.
- **`*:443` order matters too.** The first `*:443` vhost is the default for unmatched SNI, and hosts without a vhost of their own — `i.ch.oddb.org` for one — land there and get the application. A new redirect vhost placed first would redirect them instead.
- **The certificate covers only what it lists.** As of August 2026: `ch.oddb.org`, `generika.cc`, `m.oddb.org`, `oddb.org`, `oekk.oddb.org`, `www.oddb.org`. Still failing TLS: `i.ch.oddb.org`, `nachahmer.ch`, `www.generika.cc`, `anthroposophika.ch` — left that way deliberately, they are redirect-only hosts and work over `http://`. A browser that is typed into rather than linked will show a warning first; that is the whole cost. (`desitin.oddb.org` had a renewal config Apache never used; the certificate was deleted with the flavor.) A vhost cannot fix a handshake that never completes — expand the certificate first with `certbot certonly --standalone --expand -d ...`. Renewal runs nightly at 01:00 and stops Apache for the duration.
- **Anubis** (bot protection) proxies `:443` → `localhost:9000` → `8012`. It answers `curl` with HTTP 500 and "administrator has misconfigured Anubis … maybeReverseProxy" while serving browsers normally, so a 500 from `https://ch.oddb.org/` says nothing about the application — test `http://localhost:8012` to see what the app really returns. Googlebot bypasses it: `RewriteCond %{HTTP_USER_AGENT} "google"` sends it to port 8112.

### Refdata Partner API

Refdata migrated their platform on 2026-04-01. The Partner SOAP service now requires:
- **Endpoint**: `https://api.refdata.ch/partner/1.0/Partner.asmx` (was `refdatabase.refdata.ch/Service/Partner.asmx`)
- **Authentication**: `X-API-Key` HTTP header, read from `refdata_api_key` in `etc/oddb.yml` (falls back to `REFDATA_API_KEY` env var)
- Register at [developer.refdata.ch](https://developer.refdata.ch) to obtain an API key
- Used by `src/plugin/refdata_jur.rb` (companies) and `src/plugin/refdata_nat.rb` (doctors)

### Configuration

- `etc/oddb.yml` — primary app config (loaded via RCLConf)
- `etc/db_connection.rb` — PostgreSQL connection setup
- `etc/index_definitions.yaml` — ODBA index definitions
- `etc/barcode_to_text_info.yml` — barcode mappings

### Module Namespace

Everything lives under the `ODDB` module. Source files use `$LOAD_PATH` rooted at `src/`, so requires look like `require 'model/package'` not `require 'src/model/package'`.
