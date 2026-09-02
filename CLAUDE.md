# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ODDB.org is the Open Drug Database for Switzerland (live at http://ch.oddb.org). It's a Ruby web application for searching and comparing pharmaceutical products, importing data from Swiss authorities (Swissmedic, BSV), and serving drug information (FachInfo, PatInfo).

## Build & Run Commands

```bash
# Run full test suite (CI uses this; exits 2, see Testing)
bundle exec ruby test/suite.rb

# Reparse FachInfo/PatInfo text for a specific IKSNR
bundle exec ruby jobs/update_textinfo_swissmedicinfo --skip --target=both 62822 --reparse
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

### Multi-Service Architecture

The app runs alongside several daemons (in `ext/`): export, meddata, refdata, readonly, fiparse. Each is a daemontools service; `/etc/service/<name>` is a symlink to `svc/<name>/` in this checkout (gitignored). `swissreg` (code removed 2025) and `swissindex_nonpharma` (dead host) were removed as services on 02.09.2026; `ext/swissindex/` stays because `src/plugin/swissindex.rb` loads it for MIGEL. External services: Yus (auth, port 9997), MIGEL (port 33000). The main app listens on port 10000.

**Important:** The `fiparse` daemon (DRb on port 10002) runs as a separate process managed by daemontools (`/etc/service/fiparse`). Code changes to `ext/fiparse/src/` require restarting this daemon with `sudo svc -h /etc/service/fiparse` (HUP signal) for changes to take effect. The main app calls `@parser.parse_fachinfo_html(...)` via DRb, so the fiparse daemon must be running with the current code.

### Key Entry Points

- `config.ru` — Rack startup, creates `ODDB::App` via `ODDB::Util::RackInterface`
- `src/util/oddbapp.rb` — `OddbPrevalence` is the main data store (DDD aggregate root)
- `src/state/global.rb` — Root state dispatcher, routes all requests to sub-states
- `jobs/` — Import/export scripts (import_swissmedic_only, import_bsv, import_daily, export_csv, etc.)

### Testing

- **A test must never write into `test/data/`.** `ODDB::TEST_DATA_DIR` (`test/data`) holds tracked fixtures; `ODDB::WORK_DIR` (`data4tests` under test) is the scratch directory, and a setup that wipes it with `rm_rf` has already said which of the two it means. `test_plugin/swissmedic.rb` and `test_plugin/swissmedic_xlsx.rb` nevertheless passed `TEST_DATA_DIR` to `SwissmedicPlugin.new` as its **archive** — the directory the plugin downloads into — since `9d2f3503` (Feb 2024), whose commit message reads "make them touch only files under data4tests". Both point at `WORK_DIR` now, the way `test_plugin/text_info.rb` always has.
- **The damage was not local to those files.** `test/data/xls/Packungen-latest.xlsx` is read by `test_plugin/xlsx_parser.rb`, `test_plugin/text_info.rb` and `test/integration/common.rb`. `swissmedic.rb` overwrote it with `Packungen-2019.01.31.xlsx` on every run (147520 → 343091 bytes, and a dirty working tree afterwards); `swissmedic_xlsx.rb` **deleted** it outright, so running that file took the fixture away from three others. It also left `Präparateliste-<today>.xlsx` and `Erweiterte_Arzneimittelliste_HAM_31012019.xlsx` behind in `test/data/xls/`.
- **`test_get_latest_file__identical` / `__new` / `__replace` could not pass on any checkout.** Each asserts `!File.exist?(@latest)` in its first line, while `setup` deleted that file and then copied a fixture straight back onto it — two lines apart, the same path since `9d2f3503` merged them. The assertion message says "A previous test did not clean up", which sent the search in the wrong direction for a while: it was this test's own setup, not a previous test.

**Note on the test suite**: `bundle exec ruby test/suite.rb` exits **2**, not 0, and has done so throughout — two `google_ad_sense` failures left over from `ENABLED = false` in August, and `TestPreferences#test_prefs` raising `undefined method 'languages' for an instance of FlexMock`. 3872 runs over 63 files (measured 02.09.2026, after the savon/sqlite3/json bump; 3829 on 01.09.2026 before the updater, deregistration and dangling-reference tests). Check the count and the names, not the exit status.

### Troubleshooting

- **Fachinfo table formatting**: Tables from swissmedicinfo with percentage-width styles (e.g. `width:100%`, `width:99.1800%`) are rendered as preformatted column-aligned text. The `detect_table?` method in `ext/fiparse/src/textinfo_html_parser.rb` controls this. Tables rendered as HTML tables use `colspan`/`rowspan` attributes from the source HTML; these default to `1` when not specified (cells without explicit attributes must not get `0`). The view (`src/view/chapter.rb`) only emits `colspan`/`rowspan` when > 1. After fixing table parsing, restart fiparse (`sudo svc -h /etc/service/fiparse`) and reparse: `bundle exec ruby jobs/update_textinfo_swissmedicinfo --skip --target=both <IKSNR> --reparse`

- **Stale PostgreSQL connections**: If pages crash with `DBI::ProgrammingError: PQsocket() can't get socket descriptor`, the ODBA connection pool holds dead connections (typically after a PostgreSQL restart or idle timeout). The monkey-patch in `src/util/odba_connection_patch.rb` automatically reconnects on stale connections with up to 3 retries. If the issue persists, restart the app process.

- **Corrupted ODBA search index**: If searches crash with `NoMethodError: undefined method 'fetch_ids'` on a non-index object (e.g. `PatinfoDocument`), the ODBA index is corrupted. The app will display an error page telling you which index to rebuild. Fix with:
  ```bash
  bundle exec ruby jobs/rebuild_indices <index_name>
  ```
  For example: `bundle exec ruby jobs/rebuild_indices sequence_index`

### Do not update sbsm to 1.6.3

- We run **1.6.1** (`Gemfile`), though 1.6.2 is also on disk. 1.6.2/1.6.3 change 29 lines: ChronoLogger→Logger, hpricot→nokogiri.
- **1.6.3's `_validate_html` lost the sanitising.** The `unless` deciding whether a tag is in `ALLOWED_TAGS` has an **empty body**; the method now concatenates `inner_html` and strips `<body>`. Measured: input `<p>ok <b>fett</b> <script>alert(1)</script> <iframe src="x"></iframe> <a href="j">link</a></p>` → 1.6.1 gives `<p>ok <b>fett</b> alert(1)  link</p>`, 1.6.3 gives the input back unchanged. We use it for `:html_chapter` (`HTML = [:html_chapter]`), the FI/PI chapter editor.
- The real reason to move eventually: hpricot 0.8.6 is unmaintained and warns under Ruby 3.4. Fix `_validate_html` in sbsm first — it is ywesee's own gem.

### Refdata Partner API

Refdata migrated their platform on 2026-04-01. The Partner SOAP service now requires:
- **Endpoint**: `https://api.refdata.ch/partner/1.0/Partner.asmx` (was `refdatabase.refdata.ch/Service/Partner.asmx`)
- **Authentication**: `X-API-Key` HTTP header, read from `refdata_api_key` in `etc/oddb.yml` (falls back to `REFDATA_API_KEY` env var)
- Register at [developer.refdata.ch](https://developer.refdata.ch) to obtain an API key
- Used by `src/plugin/refdata_jur.rb` (companies) and `src/plugin/refdata_nat.rb` (doctors)

### Module Namespace

Everything lives under the `ODDB` module. Source files use `$LOAD_PATH` rooted at `src/`, so requires look like `require 'model/package'` not `require 'src/model/package'`.

## Fallen, die ueberall gelten

Destillat aus der Vorfall-Historie; die Geschichte dazu steht im jeweiligen Skill unter `.claude/skills/`.

- **`ODBA::Stub#is_a?` antwortet aus der Deklaration, ohne aufzuloesen.** Ein Stub, der `Array` oder `Fachinfo` deklariert, sagt ja und wirft beim naechsten Aufruf. Nur `respond_to?` loest auf, und bei totem Ziel wirft es `ODBA::OdbaError` statt false zu sagen. `instance_variable_get` auf einem Stub liest die Ivars des Stubs, nicht des Objekts: erst `odba_instance`. Der Guard, der haelt, ist `begin … .first … rescue`.
- **Eine frische Liste oder Hash in einem Ivar ist ein eigenes ODBA-Objekt.** Erst die Liste `odba_isolated_store`, dann den Halter; anders herum bleibt ein haengender Stub, und der eigene Lauf meldet trotzdem Erfolg. `nil` braucht das nicht. Reparaturen immer in einem frischen Prozess nachlesen.
- **`object_connection` ist nicht der Zugriffspfad.** Zahlen ueber Daten entstehen durch Laufen ueber die lebenden Objekte (Registrierung → Sequenz → Package → Dokument), nie durch einen Join ueber die Kantentabelle. Eine Zahl ueber 30 % ist ein Messartefakt, bis die Seiten sie bestaetigen; ein Block gleichartiger Nummern verlangt, die Objekte anzuschauen.
- **Ein `rescue` ohne Klasse ist ein Fehler, den niemand sieht.** `import_bsv` importierte zwei Monate nichts bei exit 0, `update_today` verschluckte einen Absturz. Rueckgabewerte pruefen, Signale (`SignalException`, `Interrupt`, `SystemExit`) vor `Exception` fangen und weiterwerfen.
- **`log/job.pid` sperrt `^update|^import|^rebuild|^repair` ohne Rangfolge.** Nichts Langlaufendes davon von Hand in 01:19 (`rebuild_indices`) und 05:01–08:30 (`update_today`, Feeds, `import_bsv` 08:00, `import_swissmedic` 08:15); der Tagesimport endet sonst mit "Duplicate Job" und exit 0. Reparse und Reparaturen brauchen ~4 s je Registrierung; lange Laeufe in den Hintergrund, und `pgrep -f` findet den eigenen Warteschleifen-Befehl.
- **Erst `gem push` und `bundle install`, dann den Gemfile-Pin anfassen.** Dazwischen stirbt jeder `bundle exec`-Job sofort. Ein Gem-Upgrade bekommt den vollen Testlauf und einen Bootlauf gegen die echte Datenbank, bevor neu gestartet wird.
- **Die Repo-Kopie ist nicht die laufende Datei.** `bin/oddb_cron` → `/usr/local/sbin/oddb_cron` (`sudo bin/install_crontab --apply`), `etc/20_oddb.org.rack.conf` → `/etc/apache2/sites-available/oddb-ssl.conf`. Zu jeder Aenderung gehoert der `diff` gegen die Live-Datei.
- **Ueber `:443` misst man Anubis, nicht die App.** `curl` bekommt dort immer 500; `http://localhost:8012` oder ein Googlebot-User-Agent zeigt, was die App antwortet. Ein 500 auf der ersten und 200 auf der zweiten Anfrage ist Intermittenz aus Cache- und Stub-Zustand, kein Beweis fuer oder gegen einen Fix; kalt messen oder vorher neu starten.
- **Neustarts ankuendigen.** `svc -t /etc/service/oddb` trifft die Live-Instanz; Template-Aenderungen brauchen ihn, Dateien unter `doc/resources/` nicht. `doc/resources/**/*.css` ist gitignored, eigene Stylesheets brauchen `git add -f`.
- **Ein neues Event braucht drei Stellen**: Methode auf dem State, `require`, Name in `EVENTS` in `src/util/validator.rb`. Fehlt die dritte, kommt still die vorherige Seite mit 200 zurueck.
- **Keine Passwoerter oder Keys ins Repo.** Secrets liegen in `etc/oddb.yml` (600, gitignored) und werden ueber `ODDB.config` gelesen; Skripte, die als root laufen, lesen einzelne Werte mit `sed`, sourcen nie.
- **Mail nur ueber `bin/oddb_mail`** (Google REST API gegen zdavatz@ywesee.com), nie ueber den Gmail-Connector (in diesem Repo seit 02.09.2026 per Deny-Regel `mcp__claude_ai_Gmail` in `.claude/settings.local.json` gesperrt); ausschliesslich Entwuerfe, nie senden.
- **Do not update sbsm to 1.6.3** (Sanitisierung verloren, siehe oben) und **odba bleibt exakt gepinnt** (1.2.3); `src/util/odba_18_19_compat.rb` liest alte Marshal-Dumps und darf nicht weg.

## Themen-Skills

Die Vorfall-Historie je Teilsystem liegt unter `.claude/skills/<name>/SKILL.md` und wird geladen, wenn die Aufgabe dazu passt. **Neue Notizen gehoeren in den passenden Skill, nicht hierher**; `README.md` ist ein eigener Text und bleibt davon unberuehrt.

- `odba-data-repair`: ODBA-Datenschaeden und ihre Reparatur
- `ops-cron-apache`: Betrieb: Cron, Apache, Backends
- `swissmedic-registrations`: Swissmedic-Registrierungen: De-Registrierungsdaten
- `search-console-5xx`: Search Console und die 5xx-Serverfehler
- `frontend-css`: Frontend: Dark mode, Responsive, Result list
- `bsv-import`: BSV-Import und Med-Drugs-Export
- `rss-feeds`: RSS-Feeds
- `swiyu-login`: Swiyu-Login und Anfragelimit
- `sdif-interactions`: SDIF-Interaktionen
- `drug-shortage`: Lieferengpass-Import
- `linkedin`: LinkedIn
