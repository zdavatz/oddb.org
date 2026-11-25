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

**Note on the test suite**: `bundle exec ruby test/suite.rb` exits **2**, not 0, and has done so throughout — two `google_ad_sense` failures left over from `ENABLED = false` in August, and `TestPreferences#test_prefs` raising `undefined method 'languages' for an instance of FlexMock`, all three in `test_view`. 3872 runs over 63 files (measured 02.09.2026, after the savon/sqlite3/json bump; 3829 on 01.09.2026 before the updater, deregistration and dangling-reference tests). Check the count and the names, not the exit status.

A fourth failure appeared on 20.11.2026 and was **test pollution, not a defect**: `TestGoogleSearchConsoleAuth#test_p12_without_an_email_says_what_is_missing` raised `undefined method 'gsc_service_account_email=' for an instance of ODDB::ConfigStub` — but only inside the suite run. `test/test_util/indexing_check.rb` passes on its own, and `ConfigStub` from `test/stub/config.rb` is reopened by another file in the shared batch. The file is in `must_be_run_isolated` now, after which `test/test_util` exits 0 (411 runs). **A failure that only shows in the suite run gets the file run on its own first.**

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
- **Ein handgeschriebener Setter, der `super` ruft, muss den alten Wert vorher festhalten.** `super` ist der von `define_check_class_methods` erzeugte Setter und weist das Ivar zu; was danach liest, sieht den neuen Wert. `Sequence#atc_class=`, `#patinfo=` und `#division=` gaben deshalb seit 2012 denselben Beobachter als `target` *und* `value` an `replace_observer`, sodass die alte Liste die Sequenz behielt — gefunden, weil der WHO-Import es jeden Monat nachraeumte und nie fertig wurde. `#indication=` hat kein `super` und ist die Vorlage. Dasselbe `super`-Problem macht auch deklarierte Checks zu totem Code (`Registration#fachinfo=`).
- **Ein exakter Vergleich gegen einen Fremdtext ist eine Zeitbombe.** Swissmedic hat die Werte in `production_science` mit der November-Datei 2026 von Plural auf Singular umgestellt (`"Impfstoffe"` → `"Impfstoff"`), und `/Blutprodukte|Impfstoffe/` traf danach 0 von 18137 Zeilen: `/de/mobile/vaccines/` war leer, `sequence_vaccine` auf 0 Zeilen. Schlimmer als nicht zu greifen - `args` enthaelt immer `vaccine: vaccine`, also hat der Import das bestehende `true` durch `nil` ersetzt. Auf den **Stamm** pruefen, dann zaehlen beide Schreibweisen ohne Migration; dieselbe Umbenennung hat `complementary_type` ueber drei `when`-Gleichheiten getroffen. Details im Skill `swissmedic-registrations`.
- **Das Anfragelimit zaehlt alle anonymen Besucher in einen Topf.** `SBSM::Session#remote_ip` liest `@request.remote_host`, und das gibt es in Rack 2.2.24 nicht - `remote_ip` war immer `nil`, die Limit-Seite zeigte `<>` als IP, und nach fuenf Abfragen auf einen `LIMITED`-State sah jeder die Abfragebeschraenkung. **Als Messfalle zuerst:** wiederholte `curl` auf eine `LIMITED`-Seite verbrauchen das Kontingent selbst, und danach liefert jede Seite die Limit-Seite mit Swiyu-Link - das sieht nach einer Zugangssperre aus und ist das eigene Rauschen. `localhost:8012` schuetzt vor Anubis, nicht davor. **Behoben am 25.11.2026**: `ODDB::Session#remote_ip` liest `@rack_request&.ip` - sbsm weist `@rack_request` in `process_rack` zu, bevor der State laeuft, und `Rack::Request#ip` verwirft Loopback und private Adressen als Proxy (hinter Apache ist `REMOTE_ADDR` immer `127.0.0.1`) und nimmt den **letzten** nicht vertrauenswuerdigen `X-Forwarded-For`-Eintrag, den Apache selbst angehaengt hat; ein gefaelschter Header gewinnt nichts. `remote_addr` und `user_agent` haben dieselbe Ursache und sind weiter `nil`. Wie viele Abfragen ein anonymer Besucher bekommen soll, bleibt eine Produktfrage; Details im Skill `swiyu-login`.
- **Eine Methode, die beim Lesen schreibt, darf man nicht zum Messen aufrufen.** `PatinfoDocument#change_log` setzt ein unbrauchbares `@change_log` auf `[]` zurueck und speichert — ein Zaehllauf darueber zerstoert genau das, was er zaehlen soll. `instance_variable_get` nehmen und selbst probieren. Gleiches gilt fuer `Sequence#has_patinfo?`, das einen kaputten `@patinfo`-Verweis loescht.
- **Ein `rescue` in einem `{ }`-Block ist ein Syntaxfehler** - nur `do..end` oder ein explizites `begin` erlauben es. Am 24.11.2026 viermal hintereinander hineingelaufen; `ruby -c` nach jedem geschriebenen Job faengt es sofort.
- **Loeschen in einer Schleife speichert die Liste je Durchgang.** `OddbPrevalence#delete_doctor` ruft `@doctors.odba_isolated_store` pro Arzt - bei 127779 Eintraegen hiess das 262 Loeschungen in dreizehn Minuten und 6873 in 5.7 Stunden, mit gehaltenem `log/job.pid`. `delete_doctors(oids)` loescht in einem Durchgang und speichert einmal: 6612 in 7.3 Sekunden. Wer einen Reparaturjob ueber eine ODBA-Sammlung schreibt, misst die ersten hundert und rechnet hoch, bevor er ihn laufen laesst.
- **Ein fremdes Register loescht nicht, es markiert - und ein Import, der nur berichtet, raeumt nie auf.** Refdata vergibt eine GLN nie neu und setzt Ausgeschiedene auf `STATUS != A`, der Bestand ist also kumulativ. `refdata_nat.rb` las den Status seit je, sammelte solche GLN aber nur in `@doctors_inactive` fuer den Bericht: nach acht Jahren lagen 6873 Eintraege ohne GLN im Export und 7475 mit `STATUS != A` in `@doctors` (127779 statt 109501 aktiver DoctMed). Wer einen Import gegen eine Fremdquelle schreibt, entscheidet **explizit**, was mit einem Eintrag passiert, der dort nicht mehr aktiv ist - und baut zwei Riegel ein, weil "nicht mehr aktiv" und "Export unvollstaendig" von innen gleich aussehen: bei einem gezielten Lauf nie loeschen, und ueber einem Anteil des Bestandes (`MAX_PRUNE_RATIO`) abbrechen und es in den Bericht schreiben. Details im Skill `ops-cron-apache`.
- **Eine frische Liste oder Hash in einem Ivar ist ein eigenes ODBA-Objekt.** Erst die Liste `odba_isolated_store`, dann den Halter; anders herum bleibt ein haengender Stub, und der eigene Lauf meldet trotzdem Erfolg. `nil` braucht das nicht. Reparaturen immer in einem frischen Prozess nachlesen.
- **`object_connection` ist nicht der Zugriffspfad.** Zahlen ueber Daten entstehen durch Laufen ueber die lebenden Objekte (Registrierung → Sequenz → Package → Dokument), nie durch einen Join ueber die Kantentabelle. Eine Zahl ueber 30 % ist ein Messartefakt, bis die Seiten sie bestaetigen; ein Block gleichartiger Nummern verlangt, die Objekte anzuschauen.
- **Ein `rescue` ohne Klasse ist ein Fehler, den niemand sieht.** `import_bsv` importierte zwei Monate nichts bei exit 0, `update_today` verschluckte einen Absturz. Rueckgabewerte pruefen, Signale (`SignalException`, `Interrupt`, `SystemExit`) vor `Exception` fangen und weiterwerfen.
- **`log/job.pid` sperrt `^update|^import|^rebuild|^repair` ohne Rangfolge.** Nichts Langlaufendes davon von Hand in 01:19 (`rebuild_indices`) und 05:01–08:30 (`update_today`, Feeds, `import_bsv` 08:00, `import_swissmedic` 08:15); der Tagesimport endet sonst mit "Duplicate Job" und exit 0. Der monatliche `import_refdata_nat` haelt die Sperre sechseinhalb Stunden: am 11. ab 16:10 (seit 12.10.2026, vorher 20:01, was `rebuild_indices` blockierte) bis gegen 22:40. Reparse und Reparaturen brauchen ~4 s je Registrierung; lange Laeufe in den Hintergrund, und `pgrep -f` findet den eigenen Warteschleifen-Befehl.
- **Erst `gem push` und `bundle install`, dann den Gemfile-Pin anfassen.** Dazwischen stirbt jeder `bundle exec`-Job sofort. Ein Gem-Upgrade bekommt den vollen Testlauf und einen Bootlauf gegen die echte Datenbank, bevor neu gestartet wird.
- **Die Repo-Kopie ist nicht die laufende Datei.** `bin/oddb_cron` → `/usr/local/sbin/oddb_cron` (`sudo bin/install_crontab --apply`), `etc/20_oddb.org.rack.conf` → `/etc/apache2/sites-available/oddb-ssl.conf`. Zu jeder Aenderung gehoert der `diff` gegen die Live-Datei.
- **Nicht alles in `/etc/crontab` liegt in diesem Repo.** `~/sofware/swissmedicinfo` (04:51, schreibt `data/txt/today`) und `~/sofware/sdif/update_interactions` (07:00) laufen im Home-Verzeichnis und schreiben relative Pfade dorthin; swissmedicinfo haeufte so 5.1 GB `AipsDownload_*` an und behaelt seit 30.09.2026 nur noch drei Tage. Details im Skill `ops-cron-apache`.
- **Das Speicherlimit der App misst RSS, nicht vsize** (`ODDB::App.resident_bytes`, seit 30.09.2026). vsize waechst mit jedem Thread; ein Stau langsamer Anfragen trieb oddb bei unter 1 GB RSS ueber 6144 MB und in eine Neustartschleife. Anubis 1.28.1 laeuft im Screen `anubis` mit `etc/anubis/botPolicies.yaml`; Details im Skill `ops-cron-apache`.
- **Die neun Zaehler der Startseite sind persistierte Ivars und werden fast nie nachgerechnet.** `vaccine_count` und die acht anderen lesen mit `||=` aus `OddbPrevalence`, also aus der Datenbank; nachgerechnet wird nur in `recount`, und das ruft einzig `Updater#run_random` zu zufaelliger Tageszeit — bei mehreren Neustarts am Tag erreicht der seinen Termin oft nie, und der Aufruf in `initialize` ist auskommentiert. Am 24.11.2026 stand 417 Impfstoffe auf der Startseite, richtig waren 287. `update_swissmedic` ruft jetzt `@app.system.recount_vaccines` (synchron, und **nicht** ueber `@app`: `method_missing` haelt die `@cache_mutex` und `count_vaccines` laeuft ueber `@registrations.values`). Die anderen acht bleiben ungemessen.
- **Ein laufender Server sieht nicht, was ein Job ins Wurzelobjekt schreibt.** `@rss_updates` ist in `OddbPrevalence` serialisiert; die Startseite zeigte am 02.10.2026 noch September, mit Oktober in der Datenbank - unbemerkt, solange die App zehnmal am Tag neu startete. `ODDB::App#rss_updates` liest seither alle 300 s nach, nur im Server. Wer ein weiteres Feld so ablegt, braucht dasselbe. Und **`Time#utc` wandelt den Empfaenger selbst um** (`getutc` nehmen): die Preis-Archive standen in `fr`/`en` unter dem Vortag. Details im Skill `rss-feeds`.
- **Alles, was in `ODDB::App#method_missing` laeuft, haelt die eine `@cache_mutex`, auf die jeder Request wartet.** Nie ueber `@doctors.values`/`@companies.values`/`@registrations.values` laufen, um ein Objekt zu finden (Index nehmen), und nichts Langsames dort. Haengen die Threads, zeigt `kill -TTIN <pid>` wo (`log/threads-<pid>.txt`). Der DB-Pool hat 5 Verbindungen und laesst jetzt warten statt `nil` zu geben. `method_missing` reicht keine Keyword-Argumente weiter. Details im Skill `ops-cron-apache` (19.10.2026).
- **Welche Packung welche von mehreren Patinfos bekommt, sagt der AIPS-Download** (achtstellige `RegulatedAuthorization/Identifier`, iksnr + ikscd → `SwissmedicMetaInfo#package_codes`), nicht mehr `etc/barcode_to_text_info.yml` (seit 11.11.2026 entfernt). Der Import liest die Metadaten aus `data/xml/AipsMetaCache.yml`, solange der neuer als das XML ist: wer `SwissmedicMetaInfo` ein Feld gibt, muss dafuer sorgen, dass ein alter Cache ohne das Feld neu gebaut wird, sonst wirkt die Aenderung bis zum naechsten XML nicht.
- **Ueber `:443` misst man Anubis, nicht die App.** `curl` bekommt dort immer 500; `http://localhost:8012` oder ein Googlebot-User-Agent zeigt, was die App antwortet. Ein 500 auf der ersten und 200 auf der zweiten Anfrage ist Intermittenz aus Cache- und Stub-Zustand, kein Beweis fuer oder gegen einen Fix; kalt messen oder vorher neu starten.
- **Neustarts ankuendigen.** `svc -t /etc/service/oddb` trifft die Live-Instanz; Template-Aenderungen brauchen ihn, Dateien unter `doc/resources/` nicht. `doc/resources/**/*.css` ist gitignored, eigene Stylesheets brauchen `git add -f`.
- **Ein neues Event braucht drei Stellen**: Methode auf dem State, `require`, Name in `EVENTS` in `src/util/validator.rb`. Fehlt die dritte, kommt still die vorherige Seite mit 200 zurueck.
- **Keine Passwoerter oder Keys ins Repo.** Secrets liegen in `etc/oddb.yml` (600, gitignored) und werden ueber `ODDB.config` gelesen; Skripte, die als root laufen, lesen einzelne Werte mit `sed`, sourcen nie.
- **Mail nur ueber `bin/oddb_mail`** (Google REST API gegen zdavatz@ywesee.com), nie ueber den Gmail-Connector (in diesem Repo seit 02.09.2026 per Deny-Regel `mcp__claude_ai_Gmail` in `.claude/settings.local.json` gesperrt); ausschliesslich Entwuerfe, nie senden. Das gilt fuer Mails, die Claude schreibt. Die Report-Mails der App (Cron-Jobs) gehen seit 11.11.2026 ueber die Gmail-API statt SMTP (`mail_delivery: gmail_api` in `etc/oddb.yml`, `src/util/gmail_api_delivery.rb`), weil Gmail das SMTP-Passwort von admin@ywesee.com ablehnte; seit 11.11.2026 aus `admin@oddb.org` mit eigenem OAuth-Client des Projekts `oddb-mail-cli` in der Google-Organisation oddb.org (`gmail_send_*` in `etc/oddb.yml`, Client-JSON in `~/.config/oddb/oddb-mail-cli-oauth-client.json`). Neu anmelden: `bin/oddb_mail authorize --send=admin@oddb.org`, dann mit `--code=`.
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
- `swiyu-login`: Swiyu-Login, Passkeys und Anfragelimit
- `sdif-interactions`: SDIF-Interaktionen
- `drug-shortage`: Lieferengpass-Import
- `linkedin`: LinkedIn
