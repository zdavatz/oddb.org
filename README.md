# oddb.org
* https://github.com/zdavatz/oddb.org

## Description
Open Drug Database for Switzerland. See the live version at http://ch.oddb.org

## Features/Problems
* **SDIF Interactions**: Drug interaction checking uses the [SDIF (Swiss Drug Interactions Finder)](https://github.com/zdavatz/sdif) SQLite database (`data/sqlite/interactions.db`). Four sources: EPha.ch curated ATC-to-ATC interactions, substance-level matches, ATC class-level keyword matching in Swissmedic FachInfo text, and CYP enzyme-mediated interactions. Each interaction shows its source (EPha.ch or Swissmedic FI) with type badge (Wirkstoff, ATC-Klasse, CYP). Route indicators (topisch, i.v., s.c., etc.) and approved combination therapy hints are displayed next to drug names. FI results display a "Gegenrichtung hat höhere Einstufung" hint when their severity is below the pair maximum across all interaction types. EPha results show the hint only for asymmetric EPha ratings between directions.
* Twitter share and mail/notify icons have been removed from drug search result lists.
* The `desitin` flavor was retired in August 2026 on request. Unlike just-medical it was still in use — 1206 requests from 459 distinct addresses in that month — so visitors now get the gcc default: the urls keep working, the branding and the desitin-specific result ordering do not. `LookandfeelDesitin`, its css theme and the desitin branches in `State::Global` and `Util::ResultSort` remain in the tree, so restoring the `WRAPPERS` entry revives it.
* The `just-medical` flavor was retired in August 2026: its hostname no longer resolves and the path flavor served no requests. Removing its `LookandfeelFactory::WRAPPERS` entry is what retires it — sessions asking for it fall back to `gcc`. The med-drugs xls export to `med-drugs@just-medical.com` is a separate thing and is unaffected.
* Some email-Addresses are still hardcoded. That needs to be fixed and placed into etc/oddb.yml
* If you install oddb.org via gem please also see these [instructions](http://dev.ywesee.com/Niklaus/Index).

## Requirements
* `git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build`
* `rbenv install 3.4.5`
* Linux: `sudo apt-get install apache2 daemontools daemontools-run pkg-config libmagickwand-dev libpq-dev libmagickcore-dev graphicsmagick uuid-dev`
* macOS: `brew install libpq graphicsmagick ossp-uuid` (use `bundle config build.pg --with-pg-config=$(brew --prefix libpq)/bin/pg_config` for the pg gem)
* `bzcat 22:00-postgresql_database-ch_oddb-backup.bz2 | su -c psql -l postgres -p 5433 ch_odd`
* see Guide.txt

## Useful commands
### Reparse compositions of 5 digit Swissmedic Numbers ([issue #139](https://github.com/zdavatz/oddb.org/issues/139))
`sudo -u apache bundle exec ruby jobs/import_swissmedic_only update_compositions 67685 60134`
### Reparse all compositions
`sudo -u apache bundle exec ruby jobs/import_swissmedic_only update_compositions`
### Check all packages
`sudo -u apache bundle exec ruby jobs/import_swissmedic_only check`
### Reparse FachInfo/PatInfo text for a specific IKSNR
`bundle exec ruby jobs/update_textinfo_swissmedicinfo --skip --target=both 62822 --reparse`
### Find and delete objects nothing can reach
`bundle exec ruby jobs/verify_chapter_reachability <ids.txt>` walks the live objects and checks a list of supposedly unreachable ids against them — run this before deleting anything.
`bundle exec ruby jobs/delete_unreachable_objects` counts what is unreachable per class; `--upto=<n>`, `--extent=<class>` or `--all` plus `--apply` deletes it, logging every id. `ChangeLogItem`, `Array` and `Hash` are never touched.
### Check the Fachinfo references
`bundle exec ruby jobs/repair_fachinfo_references` reports registrations whose `@fachinfo` points at something that cannot be a Fachinformation; `--apply` clears the reference. It asks the database rather than the objects — a registration legitimately references `Hash`, `Company`, `Indication`, `Fachinfo`, `Patent`, `Registration` and `MiniFi` and nothing else — because the broken value is an `ODBA::Stub` *declaring* `ODDB::Fachinfo` while resolving to something else, so `is_a?` says yes and only `respond_to?` tells the truth by fetching the object. Runs monthly from cron and exits non-zero on a find.

### Check the compositions for dead agents
`bundle exec ruby jobs/repair_dead_bag_agents` walks all registrations and reports `ActiveAgent`s that no longer resolve, plus compositions whose `@active_agents` is nil; `--apply` removes them and writes an undo log. It leaves `@inactive_agents` alone — nil is the normal state on 6885 older compositions and no damage.

### Rebuild the RSS archives
`bundle exec ruby jobs/build_fachinfo_year_feeds --apply` writes `fachinfo-<year>.rss` from the documents' change logs (about fifteen minutes for 6287 Fachinfos; runs nightly from `jobs/update_fachinfo_rss_feeds`).
`bundle exec ruby jobs/build_patinfo_year_feeds --apply` does the same for the patient information — `patinfo-<year>.rss` plus a small `patinfo.rss` with the newest fifty changes (19 minutes for 6427 Patinfos; runs nightly from `jobs/update_patinfo_rss_feeds`).
`bundle exec ruby jobs/build_price_archives --apply` rebuilds the monthly price archives from the packages' price history.
`bundle exec ruby jobs/split_rss_archives <channel>.rss --apply` cuts an existing feed into monthly files.
Each of the three is dry by default and writes only with `--apply`.

**Note:** The `fiparse` daemon (DRb on port 10002) runs as a separate process managed by daemontools (`/etc/service/fiparse`). After making code changes to `ext/fiparse/src/`, restart the daemon with `sudo svc -h /etc/service/fiparse` for changes to take effect.

### Fachinfo Table Rendering
Tables from swissmedicinfo are parsed by `detect_table?` in `ext/fiparse/src/textinfo_html_parser.rb`. Tables with percentage-width styles are rendered as preformatted text; others are rendered as HTML tables with proper `colspan`/`rowspan` support. The view (`src/view/chapter.rb`) only emits `colspan`/`rowspan` attributes when > 1 to avoid invalid `colspan="0"` in the output.

### Swiyu Login
The app uses [Swiyu](https://www.eid.admin.ch/en/swiyu) wallet-based authentication (OID4VP). After exceeding the 5-search query limit, users are prompted to log in. The login flow passes a `return_url` parameter so users are redirected back to their last search result after authentication. The verifier runs on a separate host (`swiyu.ywesee.com`, repo `swiyu4health`) and authorises ch.oddb.org by IP whitelist. As of August 2026 `SwiyuClient` sends a **DCQL query** rather than a `presentation_definition` (swiyu-verifier 4.x rejects the latter with `dcqlQuery: must not be null`) and uses `response_mode: "direct_post.jwt"` — swiyu wallet 1.17 enforces payload encryption, and a plain `direct_post` is refused with `invalid_request`. The requested credential format is held in the `CREDENTIAL_FORMAT` constant (`vc+sd-jwt`, as issued; the newer canonical `dc+sd-jwt` is accepted too). When a login fails, the wallet only ever shows `invalid_request` — the real cause has to be read from the verifier host's `/var/log/apache2/swiyu-access.log`, where a `GET …/request-object/<id>` without a following `POST …/response-data` means the wallet rejected the request object itself.

### BSV FHIR Import
The BSV SL (Spezialitätenliste) data is imported from FHIR NDJSON exports. As of June 2026, `jobs/import_bsv` uses the FHIR NDJSON source by default (mirroring oddb2xml); pass `--no-fhir` to fall back to the legacy `XMLPublications.zip` import. The dedicated `jobs/import_bsv_fhir` job remains as an explicit alias. The FHIR data follows the [ch-epl Implementation Guide](https://fhir.ch/ig/ch-epl/index.html). As of the Feb 2026 IG update, `productPrice` and `costShare` are nested inside the `reimbursementSL` extension on `RegulatedAuthorization` resources. As of April 2026, the import downloads three per-language NDJSON files directly (`foph-sl-export-latest-{de,fr,it}.ndjson`) so French and Italian product names and limitation texts are populated alongside the German source. As of June 2026, change detection no longer re-downloads the ~93 MB files every run: a cheap HTTP HEAD reads each `-latest-` file's `Last-Modified` date, derives the immutable dated link (`foph-sl-export-<YYYYMMDD>-<lang>.ndjson`), and saves it in a `<file>.source` sidecar — the download and reparse are skipped entirely while the date is unchanged. As of July 2026, the SL-introduction / price-change flags that drive the med-drugs xls export (`OuwerkerkPlugin`, sent to just-medical) are computed correctly again: `fix_flags_with_rss_logic_for` now reads the previous price via `pack.price_public(1)` (the new price has already been stored at index 0 by the time it runs), mirroring the RSS feed logic. Previously it read the just-stored current price, so new Kassenzulässigkeiten (`:sl_entry`), price cuts and price rises were silently dropped from the export while `sl_introduction.rss` still listed them. As of August 2026 limitation texts are imported again: BAG no longer inlines them in a `limitationText` sub-extension but publishes them as separate `ClinicalUseDefinition` resources referenced via `limitationIndication`, so the importer now follows that reference. Without it every limitation was skipped and only 16 legacy texts remained in the database while the export carried some 6300. The referenced resource id is the LimitationCode (e.g. `ABEVMY.07`), which BAG confirms is limitation-specific and stable across publications; the FR/IT exports use the same ids with translated text. The BAG "IndC" code (`indicationCode`, e.g. `22064.07`) is rendered as the subheading of the limitation text.

**August 2026 — BAG moved the export.** `https://epl.bag.admin.ch/static/fhir/foph-sl-export-*` became `https://epl.bag.admin.ch/static/sl/publication/fhir/foph-sl-publication-*`. The old `-latest-` alias answers 404 while the old dated snapshots stay in place, so an importer that only HEADs `-latest-` reports success every morning and downloads nothing — `import_bsv` had been doing exactly that since **14.08.2026**, exit code 0 and all. Constants `FHIR_BASE_URL` and `FHIR_FILE_PREFIX` now point at the new location, where a `-latest-` alias exists again.

Because the alias has now vanished once, `newest_dated_url` no longer depends on it: when the HEAD fails it walks back day by day from today (`DATED_LOOKBACK_DAYS`, 45) and takes the first dated file that answers, stopping at the date in the `.source` marker — nothing newer than what we hold means nothing to do. On a normal day this costs one HEAD, because `-latest-` is tried first.

### Med-Drugs XLS Export
The monthly med-drugs xls sent to just-medical (`OuwerkerkPlugin`) runs as a follower of `jobs/import_bsv` and combines registration-level change flags from the `:swissmedic` log group with package-level flags from `:bsv_sl`. As of August 2026 these change flags are **merged** into the month's existing log instead of overwriting it (`Updater#merge_previous_change_flags`, shared with the BSV path). Each import run only reports what changed since the previous download, so without the merge a second run in the same month wiped out what the first had recorded. That is exactly what happened in July 2026: Swissmedic published a corrupt "Zugelassene Packungen" file on 2026-07-04 (wrong `Packungsgrösse` on ~3200 packages) and republished it corrected on 2026-07-08; the later run compared the corrected file against the corrupt one, produced a `:size`-only mass diff and overwrote the 27 new registrations recorded by the earlier run. Since `:size` has no equivalent in `OuwerkerkPlugin::NUMERIC_FLAGS`, every Swissmedic row was then filtered out and the August export contained no new registrations. `SwissmedicPlugin#warn_if_degenerate_diff` additionally logs a `SwissmedicDiff SUSPECT` warning when a diff is dominated by a single flag, which is the signature of a corrupt file on one side of the comparison.

### Google Search Console Indexing Check
`jobs/check_indexing` verifies whether the pages behind a Search Console "Serverfehler (5xx)" report actually still fail for Google. Note what the API can do: there is **no** endpoint that lists the URLs behind the Page Indexing report — the old `urlcrawlerrorssamples` API was shut down in 2019 and never replaced, leaving only Search Analytics, Sitemaps, Sites and URL Inspection. So the candidate URLs come from our own app log (`log/YYYY/MM/DD/oddb_log`, lines with status 500) and each is looked up individually through the [URL Inspection API](https://developers.google.com/webmaster-tools/v1/urlInspection.index/inspect), which reports `pageFetchState` (`SERVER_ERROR`, `SOFT_404`, `SUCCESSFUL`, …), `verdict`, `coverageState` and `lastCrawlTime`. Quota is 2000 inspections per property per day and 600 per minute; `--limit` caps the former (default 200) and the client throttles for the latter.

Properties can be created entirely through the API, contrary to Google's own documentation, which states that verification requires user authentication and that service accounts cannot do it — the only blocker was `siteverification.googleapis.com` not being enabled in the project. `POST /siteVerification/v1/token` returns the token, `POST /siteVerification/v1/webResource` verifies it, and `webmasters/v3/sites` registers the property (that call needs the writable `webmasters` scope). `generika.cc` was verified with the FILE method and needed no DNS access at all; `oddb.org` had to go the DNS_TXT route, because its `:80` redirect answers 302 for every path except `/.well-known/` so Google can never fetch a verification file there — and a DNS property covers the subdomains anyway.

Authentication is a Google service account: the client signs an RS256 JWT with the account's private key and trades it for an access token, implemented on stdlib rather than pulling in `googleauth`/`signet`. Set `gsc_service_account_json` in `etc/oddb.yml` to the key file, and add that account's `client_email` as a **Full** user of each Search Console property (Restricted is not enough). Properties are configured per domain in `gsc_site_urls`; a `sc-domain:` property covers its subdomains, so one `oddb.org` entry serves `ch.oddb.org`, `i.ch.oddb.org`, `oekk.oddb.org` and `desitin.oddb.org`. Hosts without a property are skipped rather than spending quota — which also filters out the mangled `Host` headers some crawlers send (`chahmer.ch` for `nachahmer.ch`).

```bash
bundle exec ruby jobs/check_indexing --dry-run          # list the urls, call nothing
bundle exec ruby jobs/check_indexing --days=30 --limit=500
bundle exec ruby jobs/check_indexing --url=https://ch.oddb.org/de/gcc/... --mail
```

### Server errors reported by Google Search Console
About 25000 requests returned 500 in August 2026, on exactly the pages Google crawls. Four fixes cover roughly 24500 of them. The largest by far was every `/diff/` change-log page: Diffy tags the external `diff` output ASCII-8BIT when it is not valid UTF-8, the html formatter then re-diffs character by character and splits multi-byte sequences into single bytes, and writing those to a Tempfile transcodes and raises — but only because `config.ru` sets `Encoding.default_internal`, which is why it never reproduced in tests. `View::Drugs.utf8_diff` re-tags the text and scrubs only the genuinely invalid bytes. The rest were broken ODBA references on patinfo and fachinfo pages, where `ODBA::Stub#is_a?` answers from the *declared* class without resolving the stub, so a guard written as `is_a? Text::Chapter` passed and the next call raised; the guards use `respond_to?`, which does resolve. A related trap: `unless document&.empty?` lets a *nil* document through, because `PatinfoDocument#empty?` returns nil and so does `nil&.empty?`. The same family turned up in `view/admin/sequence.rb`, where the guard needs care: the obvious `respond_to?(:de)` would reject every real substance, since `SimpleLanguage` defines no `de`/`fr`/`it` methods and instead routes any two-letter symbol through `method_missing` with a matching `respond_to?` override. Be aware these failures are intermittent — the same URL can answer 500 and then 200 minutes later without a restart, because whether an ODBA stub resolves depends on cache and connection state, so a single URL is never proof that a fix worked. Worth knowing that the single biggest cause was not code. Three of the four rack backends were dead for days while `svstat` still reported them up — `crawler` for 18.6, `generika` for 10.3, `google_crawler` for 9.7 — and Apache answered every request to those ports with a 503 for the duration. `svstat` reports on `supervise`, not on the child, so counting requests per day in `log/YYYY/MM/DD/<service>_log` is what makes an outage visible. `oddb_cron healthcheck` now asks the four ports every minute and restarts a backend that has been silent for five, which is well past the normal restart cycle these processes go through whenever they pass their memory limit.

A second measurement trap: Anubis answers `curl` with a 500 while serving browsers normally, so a URL tested from the shell can look broken when it is not. Send a Googlebot user-agent, which bypasses Anubis, or probe `http://localhost:8012` directly.

A second round on 28.08.2026 brought the rate from 1.3 % (15.4 % on 15.08., while the backends were dead) down to **0.13–0.15 %**, on ten times the traffic — requests went from ~22 000 to ~250 000–340 000 a day once the dead backends came back. Two causes were left. A Latin-1 umlaut in a chapter heading raised `Encoding::UndefinedConversionError` on every `minifi` page of the affected drug: `#formats` has always converted `ASCII-8BIT` as ISO-8859-1 for paragraph text, the heading did not, and what stood there could not have worked — the repair ran *after* the heading was built and `head.encode("utf-8")` threw its result away. And a string where a document belongs took the Fachinfo page down through four layers in a row, each guard only uncovering the next; `Drugs.change_log_size` moved from `patinfo.rb` to `change_logs.rb`, which `fachinfo.rb` already loads. Ask `respond_to?` with a **Symbol**, not a String: `SimpleLanguage#respond_to?` takes either, but FlexMock answers only symbols, so a String guard passes in production and fails three existing tests. Three registrations were a data defect rather than a code one — they held a `PatinfoDocument` under `@fachinfo`, every guard just moved the failure one line down, and Google had crawled one of them and filed the server error. `jobs/repair_fachinfo_references` cleared them; they answer 404 now, like every other registration without a Fachinfo. Note that a large share of what remains in the log is not a real page at all: `/dt/gcc/…` uses a language code that does not exist, and `month/Arial`, `api/v1/validate/code` and `test/lm.php` are bot probes. Count distinct valid urls before concluding there is a bug.

A third round on 29.08.2026 came from reading our own log rather than the Search Console — of the 28 urls that had answered 500 in three days, Google's URL Inspection API called every single one "unknown to Google". All 28 answer 200 now, on a cold cache. The lesson that cost the most: **a dangling reference is not a reference of the wrong class, and `respond_to?` cannot tell you about the first.** It *resolves* the stub, so when the target is gone it raises `ODBA::OdbaError` instead of answering false — which is exactly what the August guards in `view/admin/sequence.rb` walked into. `View::Admin.resolvable_agents` and `.any_agent?` rescue it now; without the rescue one bad element takes the whole sequence page down. Note also the asymmetry between two encoding repairs that look identical: `ASCII-8BIT` means UTF-8 bytes in `view/tooltip.rb` and Latin-1 in `view/chapter.rb`, so `TooltipHelper.to_utf8` tries the first and falls back to the second — `encode("UTF-8")` alone cannot move a single byte over 0x7F out of an ASCII-8BIT string, it raises. And these pages answered 500 on the first request and 200 on the second, which is why a crawler always saw the error and a hand check never did: probe a *cold* url, or restart first.


### Cron
`/etc/crontab` and every script it calls are versioned as `etc/crontab` and `bin/oddb_cron`. Install both with `sudo bin/install_crontab --apply`, which backs up what it replaces; installing the crontab alone breaks every job, because it calls `/usr/local/sbin/oddb_cron`. One line covers all nine ch.oddb.org jobs — `* * * * * zdavatz /usr/local/sbin/oddb_cron schedule` runs every minute and the times live in a table inside the script (`oddb_cron schedule-list`). The certbot and backup lines stay separate because cron takes one user per line and those run as root; the install step makes the script root-owned, which also closes a pre-existing hole where cron ran a zdavatz-owned backup script as root. Job output goes to `log/cron/<job>-<YYYY-MM>.log` instead of the `>/dev/null 2>&1` the old lines carried — a failing import used to look exactly like a successful one. The same schedule line also runs `oddb_cron healthcheck`, which probes the four rack ports and restarts a backend that has been silent for five consecutive minutes; the grace period matters, because these processes restart themselves whenever they pass `MEMORY_LIMIT_CRAWLER` and need about forty seconds to answer again, so a check firing on that would be worse than none. Its escalation is covered by `sh test/test_bin/healthcheck.sh`, which stubs `curl`, `svc` and `svstat`.

Since 28.08.2026 the nightly Postgres dump is versioned too, as `scripts/pg_backup.sh`, and `install_crontab` puts it in place — but only once `etc/oddb.yml` holds `db_password`, because the versioned copy carries no password and installing it without one would turn the backup into a silent failure. That password used to sit in two world-readable files, `etc/db_connection.rb` at 644 and `/usr/local/sbin/pg_backup.sh` at 755; it lives in `etc/oddb.yml` now, mode 600, where every other secret already is. The script **reads** it rather than sourcing the file: it runs as root while `oddb.yml` belongs to the web user, so a `.` on that file would be a path from a compromised application to root — `sed` lifts one value and executes nothing. Watch out for the trap that cost a leak here: `install_crontab` prints the diff of what it replaces, so before it was filtered a plain dry run put `-PGPASSWORD='...'` on the terminal. Covered by `sh test/test_bin/pg_backup.sh` and `sh test/test_bin/install_crontab.sh`.

The script asks psql which databases exist and recognises the footer of that table by its wording, `(4 rows)`. Under `de_CH.UTF-8` psql writes `(4 Zeilen)`, the `grep` misses it, and `awk` hands back `(4` as a database name — which is why a 14 byte `(4-backup.bz2` sat beside the real dumps every night. `LC_ALL=C` on that one query pins it (29.08.2026). The test runs the script's own `db_connectivity` against a psql stub that answers German unless `LC_ALL` is `C`, so taking the pin out makes it fail.

The schedule also carries a monthly `repair_fachinfo_references` on the 5th at 06:30. It changes nothing without `--apply` — it only reports registrations whose Fachinfo reference points at something impossible, and exits non-zero so cron mails. The check on the writing side is in `Registration#fachinfo=`; `check_accessor_list` had declared it for years, but `define_check_class_methods` runs at line 60 and the hand-written setter twenty lines further down overrode the generated method, so the declared check was dead.

### Apache vhosts
Apache reads `/etc/apache2/sites-available/oddb-ssl.conf`, not the repo copy in `etc/20_oddb.org.rack.conf` — the two had drifted, so both need changing. A catch-all `*:80` vhost must stay first: Apache serves the first `*:80` vhost for any unmatched Host header, and that used to be `sl_errors.oddb.org`, so `http://oddb.org/` and bot probes with mangled hosts got a directory listing of `doc/sl_errors`. Note that `Redirect /` appends the remaining path, so a target without a trailing slash concatenates — `http://generika.cc/de/generika/` redirected to `https://generika.ccde/generika/`; use `RedirectMatch` where the path should be dropped and a trailing slash where it should be kept. Putting a host in the wrong category is silent rather than broken: four vanity domains pointing at landing pages were given the trailing-slash form, so `/de/generika/` arrived at `/de/anthroposophy/home/de/generika/`, which answers 200 because SBSM ignores the tail. A redirect-only host should also be `permanent` — `www.generika.cc` answered 302 for years, which is why a legacy Search Console property for it kept crawling and reporting 5xx. The certificate covers only the names it lists, so a vhost cannot fix a handshake that never completes; expand it with `certbot certonly --standalone --expand`. Finally, Anubis (bot protection, `:443` → `localhost:9000` → `8012`) answers `curl` with HTTP 500 while serving browsers normally, so a 500 from `https://ch.oddb.org/` says nothing about the application.

### Refdata Partner API
Refdata migrated their platform on 2026-04-01. The Partner SOAP service (used for company and doctor imports) requires an API key. Set `refdata_api_key` in `etc/oddb.yml` (or the `REFDATA_API_KEY` env var). Register at [developer.refdata.ch](https://developer.refdata.ch) to obtain a key.

### Drug Shortage Import
`jobs/update_drugshortage` imports current Swiss drug shortages from [drugshortage.ch](https://www.drugshortage.ch). In May 2026 the upstream site migrated from an ASP.NET HTML page to a WordPress + JSON API; the plugin fetches `https://www.drugshortage.ch/api/api_engpaesse.php` (the official "show all current shortages" endpoint, ~705 active records — endpoint moved under `/api/` in June 2026) and parses `gtin`, `mutation`, `status`, `lieferdatum`, `id` per record. `status` values gained a leading category-number prefix (`"1 aktuell keine Lieferungen"`), which the plugin strips to keep `shortage_state` stable. `shortage_link` is built from the stable upstream `id` as `https://www.drugshortage.ch/index.php/detail-lieferengpass/?ID=<id>`. Cached fixture lives at `data/json/drugshortage-latest.json`. Later in June 2026 the API also began requiring HMAC-signed requests (otherwise HTTP 403 `"Zugriff verweigert – fehlende Header"`): each call sends `X-Timestamp`, `X-Nonce`, an `X-Signature` (`HMAC-SHA256(secret, "<ts>|<nonce>|api_engpaesse")` as hex) and `X-Requested-With`, generated per request by `ShortagePlugin#shortage_source_headers`.

### Stale PostgreSQL Connections
If the app crashes with `PQsocket() can't get socket descriptor`, the ODBA connection pool holds dead database connections. A monkey-patch in `src/util/odba_connection_patch.rb` automatically detects stale connections and reconnects with up to 3 retries. This handles PostgreSQL restarts, idle timeouts, and other connection drops transparently.

### Rebuild corrupted ODBA search indices
If searches fail with `NoMethodError: undefined method 'fetch_ids'`, an ODBA index is corrupted. The app will show an error page with the index name. Rebuild it with:
`bundle exec ruby jobs/rebuild_indices <index_name>`

For example: `bundle exec ruby jobs/rebuild_indices sequence_index`

### Orphaned Fach- and Patinfo diffs
A `change_log` lives on the `FachinfoDocument` / `PatinfoDocument`, not on `Fachinfo` / `Patinfo`. Replace a document without carrying the history over and nothing points at it any more. In August 2026 **31447 of 125403 change log items** — a quarter of the entire diff history — were unreachable: `/show/fachinfo/51886/diff` listed 7 revisions with 61 more from 2015–2017 lying beside them, `/show/patinfo/49537/01/002/diff` listed none at all against 59 stored ones. All the drugs still existed; every `Registration`, `Sequence` and `Migel::Item` was reachable, so what was lost were superseded *versions of the texts*.

**The cause, found 26.08.2026.** `PatinfoDocument#add_change_log_item` compares the new diff against the existing ones to skip duplicates, and the rescue around that comparison read `@change_log = [item]` — so one entry that stumbled replaced the whole change log with the single new item. Comparing calls `x.diff.to_s`, which runs Diffy, which writes two tempfiles and shells out to `diff`, and that is where this data's encoding trouble lives. The Fachinfo version of the same method only logs and leaves the list alone, which is why the PI side lost five times as much. Found by snapshotting every reachable `change_log` id per registration, waiting for one `update_today`, and diffing: 2 entries gone out of 22 Patinfos stored, both `PI de`. Three earlier explanations had been reasoned out and all three died on measurement. Stopping is not restoring: 47 `Patinfo` objects over 40 registrations have no document left at all, and only 5 of those have an orphaned diff to rebuild from — the rest need a reparse from swissmedicinfo. See [issue #446](https://github.com/zdavatz/oddb.org/issues/446).

`jobs/repair_orphaned_change_logs` hangs them back on. Attribution comes out of the text itself: every Fach- and Patienteninformation ends with its registration number, and `Diffy::Diff` stores the complete old and new text, so the entry carries its own drug with it — which is also why the database is 19 GB. It runs in two steps so what gets written is a file somebody can read: `--plan` writes `item, document, verdict`, and `--from-plan --apply` attaches exactly those pairs without deciding anything again. The verdict is a check against the target: does the document's own text carry the same number? 20167 said yes, 721 said no — often a neighbour like 59410 against 59411, the same substance in another strength — and those were left alone. 20105 were reattached, taking the orphans down to 11340.

Note that `odba_isolated_store` on a document does **not** write its `change_log`: that is a separate ODBA object with its own `odba_id`, replaced by a stub when the document is dumped. The list has to be stored itself, before the document. Getting this wrong produces a run that reports success and changes nothing — and the same shape of mistake sits in the data already, as 7614 dangling edges where an object references a child that was never written (4091 of them on `Package`, 1120 on `SimpleLanguage::Descriptions`).

### The 7.5 GB nobody could reach

Every update of a Fach- or Patienteninformation builds a new document, and `SimpleLanguage#update_values` puts it where the old one stood. Nothing deleted the old one — with its twenty chapters. On some 6300 live Fachinfos that had grown to **200 000 superseded document versions and 3 953 085 chapters**: 7.5 of 19 GB, and about 20 000 documents a year. The same mechanism that once cut the diff history loose.

Reachability was measured twice, and the second measurement is what made it safe to act. A breadth-first walk of `object_connection` from the named, the `prefetchable` and the index-referenced objects; and `jobs/verify_chapter_reachability`, which walks the live objects instead — registration to document to chapter. It reached 286 639 chapters and found **not one** of them in the set the first method calls unreachable. That the same search also returns exactly the 11 340 orphaned change-log items the August repair left behind is what makes it trustworthy.

The first verification run reported 1261 chapters and no contradiction at all, which looked like a clean bill of health and was worthless. `reg.fachinfo` hands back an `ODBA::Stub`, whose own instance variables are only `@odba_id` and its siblings — walking them finds nothing and reports calm; only a method call resolves the stub. And the chapters are not instance variables: `document.chapters` returns the *names* as symbols, and `document.send(name)` is what yields the chapter.

Three classes are never touched: anything ending in `ChangeLogItem`, and `Array` and `Hash`. 31 370 diffs hang on those old documents, 20 105 of them reattached to live documents in August and on the `/diff/` pages today, and the `Array`s are the change-log lists. `ODBA::Cache#delete` does not cascade — it deletes the object and cuts the references to it — but it also does a query per object and rewrites every referrer, which is hours for four million. So the deletion is batched SQL and therefore not reversible; a `pg_dump -Fc` comes first, 8.47 GB in a few minutes against the 63 the nightly plain-plus-bzip2 backup needs.

`EphaInteraction` went along, all 207 490 of them. The class was removed in March 2026 with "Replace EPHA CSV interactions with SDIF SQLite database"; `defined?(ODDB::EphaInteraction)` answers nil, so nothing could load one even in principle.

Seven stages, smallest class first, a restart and a page probe after each: 4 399 175 objects deleted, 7 114 259 → 2 715 084, and after a `VACUUM FULL` of two minutes the database went **19 GB → 9.66 GB**. Every id is logged.

None of which would have lasted. `ODDB::SupersededDocument` deletes the replaced document and its chapters at the point where it is replaced, hooked into `SimpleLanguage#update_values` — the one place both Fachinfo and Patinfo pass through — and into `replace_textinfo`, which writes into the hash directly and would otherwise slip past. Nothing is lost by it, and that is the whole reason it is allowed: `store_fachinfo` carries the change log into the new document, and a `Diffy::Diff` stores the complete old **and** new text, so every entry is a whole version by itself. Only the newest is ever displayed. Two guards: the change log is taken out of the old document before it falls rather than trusting that delete does not cascade, and a chapter the successor also uses survives — the parser builds each chapter anew, but that is an assumption about someone else's code, and a wrong one would cost a live drug its text.

Verified with a reparse: document 61893094 with 19 chapters and 9 diffs before, document 61894333 with 19 new chapters and the same 9 diffs after, and the old document and its chapters gone from the database.

### Dangling ODBA references
`checkout` deletes an object's children from the database. Until August 2026 it left the reference standing: `Package#checkout` called `odba_delete` on `@sl_entry` and `@parts` and cleared neither, so the package kept a stub to something that no longer existed. **3950 packages** were in that state — every `package.limitation` and `limitation_text` raised `ODBA::OdbaError`, while price, deductible, generic type and name came from other fields and kept working, which is why nobody noticed. `delete_sl_entry`, twenty lines below in the same file, had always done it right. `Sequence`, `Registration` and `Composition` had the same shape and got the same fix. Note there is deliberately no `odba_isolated_store`: `checkout` runs immediately before or after the `odba_delete` of the object itself, and storing would recreate what was just deleted.

`jobs/repair_dangling_references` cleans up what the bug left behind — the edge list comes from `SELECT c.origin_id, c.target_id FROM object_connection c WHERE NOT EXISTS (SELECT 1 FROM object o WHERE o.odba_id = c.target_id)`. It clears the ivar rather than restoring the target, because there is nothing to restore: of the 3924 affected packages only 135 are still in the BAG export, the other 3789 have left the Spezialitätenliste, so the reference was not just broken but moot. 4410 objects cleaned, dangling edges down from 7502 to 3258, and `limitation` answers on 300 of 300 sampled packages instead of failing on 292. Among them 257 `@connection_keys` on `Substance` — an ivar that appears nowhere in the code or in the odba gem any more.

What is left alone: the 1120 `SimpleLanguage::Descriptions`, whose broken links are hash entries rather than ivars. 6652 probes of the ATC guidelines they serve raised nothing, because `Text::Document` declares `@descriptions` as `ODBA_SERIALIZABLE` and no longer follows that path at all.

### Ghost packs in the BAG export
The SL export lists some packs **twice under one Swissmedic number**: once properly, with a GTIN and the pack price, and once without a GTIN, described as "1 Stk", carrying the price *per unit*. Both resolve to the same package through `package_by_ikskey`, both prices get written, and what survives is whichever came last. On 25.08.2026 Enflonsia stood at 354.60 instead of 3545.85 and Menveo at 37.75 instead of 188.75 — a tenth and a fifth of the real price. Encepur, FSME Immun Junior and Comirnaty happened to end on the right value, which is the same bug wearing a friendlier face.

`BsvFhirPlugin#ghost_pack?` drops a GTIN-less pack **only when another pack with a GTIN shares its number**. A blanket filter would have been wrong: 55 of the 10255 packs have no GTIN and 49 of those are the only pack under their number (Candesartan CPS and others), entirely legitimate. `jobs/repair_ghost_pack_prices <gtin>=<preis> --apply` fixes what is already stored — the filter prevents recurrence but does not repair. Reported to BAG; see [issue #445](https://github.com/zdavatz/oddb.org/issues/445).

Worth knowing for any price question: comparing all stored public prices against the GTIN-matched prices in the export takes a few minutes and gives a flat answer — 10010 of 10013 matched, one pack had no price here, and the two above were the only wrong ones.

### Mail drafts
`bin/oddb_mail draft --to=… --subject=… --body=datei` creates a draft in `zdavatz@ywesee.com`. Only ever a draft, never a send.

Two routes to a token. A **service account** would have to impersonate the mailbox, which needs domain-wide delegation in the Workspace console (`admin.google.com` → Security → Access and data control → API controls) and answers `Client is unauthorized to retrieve access tokens` until an admin adds the client id with the `gmail.compose` scope. An **OAuth client** asks the mailbox owner once instead and a refresh token carries it from there — no admin, no delegation. `bin/oddb_mail authorize` walks through it; the browser lands on `http://localhost` and fails to load, which is expected, and the `code=` is copied out of the address bar. `GmailApi` prefers OAuth and falls back to the service account, which exists anyway for the Search Console.

Two traps sit in the Google side of this. Its token endpoint returns `error` as a plain **string** while the other services return an object with `message`, so `parsed.dig("error", "message")` raises `TypeError` and hides the very message you need — the same line still sits in `google_search_console.rb`. And `RCLConf` raises `NoMethodError` for keys that are not set rather than returning nil, so the usual `|| default` never runs. Secrets live in `etc/oddb.yml`, gitignored and mode 600.

### Indices that never rebuilt

`jobs/rebuild_indices` failed on six indices every night from at least January 2026 until 26.08.2026, and reported it to `/dev/null` — `substance_index_atc` had no table at all, because the index is dropped before the rebuild and the rebuild never finished. Three unrelated causes: a Latin-1 string that `valid_encoding?` calls valid, so the encoding guard passed it straight into a UTF-8 regexp; one corrupt object out of 41801 that cost two entire indices, because they call `.substance` on every element of `active_agents`; and an index definition resolving its target with `active_sequences`, a method that exists on the app and not on `Substance`. See [issue #447](https://github.com/zdavatz/oddb.org/issues/447).

Two things worth carrying away from that hunt. `ODBA::Stub#is_a?` answers from the declared class **without resolving**, so a broken reference passes every `is_a?` check in the codebase — only `respond_to?` resolves and tells the truth. And `Array#delete` cannot remove such an element, because comparing it is what resolves it: use `object_id`, which is on ODBA's no-override list, never `equal?`, which is not.

`jobs/repair_broken_active_agents` rebuilds a lost agent from the composition text by position, and refuses to act unless the intact neighbours sit where the text puts them.

### The eight dead ActiveAgents, and the lists that were never there

Walking all 15018 registrations on 29.08.2026 turned up eight sequences carrying an `ActiveAgent` that no longer resolves — always in the BAG composition, never in the Swissmedic one, and the dead ids consecutive (55257061..63, 55257069..72) on the alphabetically first drugs. That is the handwriting of a job that worked through the list in order and died after the eighth.

**The cause was still in the code, in both BSV importers.** `add_bag_composition_to_sequence` cleared the old agents by hand and got three things wrong at once: it iterated the very list `delete_active_agent` deletes from, so with two agents the second is never visited; it called `agent.odba_delete` **unconditionally**, also when `delete_active_agent` had found nothing and left the reference standing, which is precisely how a dangling stub is made; and once one was in the list every comparison over it threw, because `Array#delete` compares with `==` and `ActiveAgentCommon#==` calls `.substance` on the other side. That throw disappeared into the method's own `rescue`, so the composition was simply never updated again. Both plugins call `Composition#delete_all_active_agents` now, and two regression tests fail against the old loop.

Nothing could be restored, and that is a property of the data: BAG compositions carry no `source` text, unlike the Swissmedic ones `jobs/repair_broken_active_agents` rebuilds from. The next BSV import writes new agents as soon as the drug is in the SL again. **Repairing this made it worse once**, which is the part worth remembering: setting `@active_agents` to `[]` and calling `odba_isolated_store` on the *composition* traded a harmless nil for a dangling `Array` stub, because the list is its own ODBA object with its own `odba_id` and is replaced by a stub in the holder's dump — it has to be stored first, by itself. The job's own run reported success; only re-reading in a fresh process showed it. And `is_a?(Array)` passes for that stub too.

**A related nil that is not damage.** `@inactive_agents` is nil on 6885 of 36112 compositions — all on the Swissmedic side, none on the BAG side, and only 12 of them on an active registration. Hilfsstoffe were introduced in 2015 and everything older never got the ivar; the reader answers `[]`, so the pages are fine and normalising it would be 6885 writes for nothing. Two pieces of code did not cope, though. `create_inactive_agent` reaches past the reader (`@inactive_agents.push`) and raises `NoMethodError` there — and that error falls into the bare `rescue` in `SwissmedicPlugin#update_all_sequence_info`, which files it as `"unparsed_composition"`: 54 such lines in August, 358 in July, not one carrying an exception. The guard that should have caught it was dead code — `if composition.inactive_agents … else …` can never take the else branch, because the reader returns `[]` and `[]` is truthy, so the `replace` in the if branch ran on a throwaway list and silently dropped what had been parsed. Worth knowing generally: **`replace` on an agent list does not persist by itself**, since `odba_store` on the holder only carries a child along while it is `odba_unsaved?`, which after a plain replace it is not. `Composition#replace_active_agents` and `#replace_inactive_agents` create the list where it is missing and write it themselves, before the holder.


### Dark mode

A toggle in the top right corner switches between light and dark; the choice lives in the browser and follows `prefers-color-scheme` until someone decides otherwise. `doc/resources/dark.css` is an overlay keyed on `html[data-theme="dark"]`, so without that attribute it does nothing and the light page is untouched — worth insisting on, because the file is embedded into every page. One overlay serves all eight flavor stylesheets, which share 249 of 253 selectors.

The overlay is **generated** from the source stylesheets — `python3 bin/generate_dark_css.py doc/resources/gcc/oddb.css doc/resources/diff.css` — and a test fails if any source rule has no dark counterpart. Enumerating by hand missed 77 rules, and a generic `html[data-theme="dark"] a` loses on specificity to `a.subheading:link`, which is why links stayed dark blue at 2.1:1 on a dark ground. Prefixing the source's own selector is always more specific than the original and later in the cascade.

The generator has two blind spots, both found in August 2026 by measuring contrast on rendered pages rather than reading CSS. It reads `oddb.css` and `diff.css` — so it never saw `background: #eee` on `pre`, which arrives via the `@import` of the vendored `tundra.css` and is where the Fachinfo's column-aligned tables live (1.2:1). And it cannot see **inline styles written from Ruby**: the interaction severity colours and the source, route and combination badges in `sdif_interaction.rb` are set as `style="background-color: …"`, which left light text on pink at 1.7:1 and "Quelle: EPha.ch" at 1.1:1. Both are handled in the hand-written tail of `dark.css`; the inline case is covered by a general rule, which is safe because every inline background in the application is light. Figures in Fach- and Patienteninformation get a white plate rather than an inversion — in a medical figure the colours carry meaning.

A third correction came from reading rather than measuring: the diff lines kept their own colour, green text on a green ground and red on red, which clears the contrast bar at 7.4:1 and 8.3:1 and still reads badly line after line. The line keeps its ground — that is what carries the meaning — and the text moved to the reading colour, 9.1:1 and 10.8:1. The rule sits behind the generator marker, because everything above it is overwritten on the next run.

It deliberately does not use the existing colour choice (`:styles`, `oddb-blue.css` and siblings). That mechanism has been dead since the stylesheet started being inlined rather than linked: `css_link` substitutes `oddb.css` for `oddb-<style>.css` inside a `<style>` block whose content is the CSS itself, where the filename never appears — which is why picking blue or red today only changes the logo.

### Font sizes and screen widths

The page has declared `width=device-width` for years and then shipped a sixteen-column table with fixed pixel widths and **not one media query** — in none of the nine stylesheets. On a 390px phone the screen ended after the fourth column.

`doc/resources/responsive.css` is an overlay on the same pattern as `dark.css`: one file keyed on the shared class names, appended after `oddb.css`, covering all eight flavors. Two rules govern it and both are enforced by `test/test_view/responsive.rb` — **every declaration sits inside a media query**, so nothing outside the three breakpoints changes for anybody, and **it sets no fixed colours**, because it is embedded into every page and has to be right in dark mode too.

Three breakpoints. Desktop from 1025px stays dense — 13px instead of 12px, row padding 4→7px, tabular figures for prices, a header that stays put while scrolling; whoever compares prices wants rows, not air. Below 1025px the columns nobody reads at that width drop out. Below 640px each pack becomes a card.

The columns could not be addressed by position: `result_list_components` is overridden six times in `lookandfeelwrapper.rb`, so the public price is the ninth column in gcc and the eighth or fifth elsewhere. `View::LookandfeelComponents#reorganize_components` now appends the column key as a class — `col-price_public` means the same everywhere — and that one change is what makes the card layout possible at all.

Two of the fixes were **specificity**, the same trap dark mode fell into: `table:has(…) > tbody > tr { display: block }` scores (0,1,4) and beat `tr:has(> th.col-name_base) { display: none }` at (0,1,2), so the header row survived and the cards stacked as blocks. And a generic `> td { display: block }` at (0,1,3) quietly undid the column hiding one breakpoint up.

On a phone the zone navigation shows four of its eight entries — Medikamente, Interaktionen, MiGeL and Services. Eight broke onto three lines at 390px and pushed the search box off the first screen. They are picked by the `name` attribute, which is written in the code and is the same in all three languages, not by the label — "Apotheken" is "Pharmacies" in French. And only where the row is long enough to wrap: `:nth-child(9)` asks for at least five entries, so generika with three and oekk with two keep all of theirs. The four still did not fit at 410px against 393, until the cells gave up the 8px they carry on each side from `oddb.css`; the spacing is already inside the link, whose tap target is 40px tall.

The 16px on inputs is not taste: Safari zooms the whole page when a field under 16px takes focus, and does not zoom back out.

Two things CSS turned out not to be able to do here, and both are in `doc/resources/javascript/compactdetail.js` instead. A cell holding only `&nbsp;` is not `:empty` and CSS cannot look at text, so blank field pairs in the detail view and blank cells in the cards are hidden by script — 12 pairs on a detail page, 58 cells on a result list, 73 on the query-limit page. And `flex-grow` cannot force a line break: a flex container fills a line first and distributes leftover space afterwards, so the FI/PI marks kept sliding up beside the price whenever the name and price left room. An empty cell with `flex-basis: 100%` in front of the first mark is what actually breaks the line.

The recurring mistake was specificity, four times in one day. The rule that turns the nested layout tables into blocks carries a `:not(:has(…))` per exception, and each one raises its specificity above anything further down that wants a different `display` — it beat the card rows twice, then the header rows, the chapter navigation and the footer. Exceptions belong in that rule, not in an answer to it. The other half of the same lesson: `table.composite` is both the page skeleton and real data tables, and the difference is that a data table has a `th` header row. Treating both alike turned a package list into a column of right-aligned single values.

### External links

Every link to a foreign host — ywesee.com, swissmedic.ch, drugbank.ca, the app stores, whatever a Fachinfo happens to link — opens in a new tab, with `rel="noopener noreferrer"`, because without `noopener` the opened page can reach back through `window.opener`. One script rather than edits in the views: the links are built in over two hundred places, and a good part of them sits inside text that comes out of a parser. Own-host links stay put, absolute ones included; `mailto:`, `tel:` and bare anchors are skipped.

### The RSS feeds as pages

Clicking a feed on the home page used to land you in raw XML. `jobs`-generated feeds now also render as HTML in the site's own look and feel — `/de/gcc/rss_html/channel/recall.rss`, opened in a new tab from the feed title, while the feed icon still points at the XML.

`ODDB::RssReader` reads the file **line by line**, deliberately without an XML parser: `fachinfo.rss` is 237 MB, and a DOM of it per request would be a multiple of that. Descriptions are shown only when they are short and not a whole HTML document — the price feeds carry a rendered 28 KB detail page in every item.

Reading a whole year of Fachinfo took **52 seconds**, and only 0.66 of those were the file. The reader ran four interpolated regular expressions against each of 3.7 million lines, and an interpolated pattern is recompiled on every call. Now it is one expression anchored at the start of the line, the indentation of a field is taken from the `<item>` line above it so the test per line is a prefix comparison, and a line too long to be a usable description is skipped before either. **2.3 seconds**, all 2871 entries complete, and every one of the 2871 archive files still reads back exactly as many items as it holds.

The pages page by year, the way `/recent_registrations/` does, and the title says which period is on screen. **The entry page is the newest year**, not a window of the newest fifty: `update_price_feeds` overwrites `sl_introduction.rss`, `price_cut.rss` and `price_rise.rss` with a single month on every run, and a page fed from those files showed July while January to June sat beside it in the monthly archives. The years in the chooser were right the whole time; only the page one lands on was wrong, which is the kind of fault that gets reported as missing data.

The history itself is written once and read from files. `jobs/split_rss_archives` cuts an existing feed into `<name>-YYYY-MM.rss`; `jobs/build_price_archives` reconstructs the three price channels from the packages' own price history in a single pass — 55 049 changes over 20 401 packages, back to the 1980s. It does not go through `View::Rss::Package`, which computes `price_public(0)` against `(1)`, so an archive built through it showed today's price under a date from 2019. Note that the earliest entries are not events: the oldest `price_cut` is dated 1955 and names a Ramipril generic, and Ramipril was patented in 1981 — that is a placeholder `valid_from`. One per cent of the entries lie before 2000.

The Fachinfo yearly feeds were a different kind of wrong. `update_yearly_fachinfo_feeds` built them from `app.sorted_fachinfos` — the Fachinfos as they stand today, grouped by the year of their **last** revision. Each has exactly one revision date, so each landed in exactly one year: measured, 5053 distinct Fachinfos across all yearly files and three of them in more than one year. That is a partition of the stock, and it erodes, because a year keeps only what has not been touched since — February 2026's mass reparse pulled 2191 documents out of their earlier years, leaving 2025 with 66 entries against 2871 for 2026. A drug rewritten in 2019, 2022 and 2025 belonged in all three and appeared only in the last.

`ODDB::FachinfoYearFeeds` builds them from the documents' `change_log` instead — the same source the `/diff/` pages read — one entry per Fachinfo and date, linking to the diff. Per Fachinfo and not per registration: a Fachinfo belongs to 2.3 registrations on average and the text changed once, not twice. `jobs/build_fachinfo_year_feeds` is the one-off, dry by default; `jobs/update_fachinfo_rss_feeds` uses the same class nightly.

Walking that graph needs `odba_retire`. A `FachinfoDocument` carries the whole text and a `ChangeLogItem` carries the old one **and** the new one — the double storage behind the 19 GB database. Reading 1500 Fachinfos stood at 2.7 GB and rising linearly; all 6287 would have passed ten. Neither `ODBA.cache.clean` nor nulling the instance variable helps, because the application's own `@fachinfos` hash and the memoized `@sorted_fachinfos` array hold every object alive. `ODBA.cache.fetch_cache_entry(id)&.odba_retire(force: true)` replaces the object with its Stub in everything that holds it — what ODBA itself does under memory pressure, and it writes nothing. Flat at 280 MB afterwards.

The patient information got the same treatment in August 2026, and the body is now shared: `ODDB::YearFeeds` holds it, `ODDB::FachinfoYearFeeds` and `ODDB::PatinfoYearFeeds` differ in where the documents come from and how an entry is linked. Both differences on the Patinfo side follow from the address of the diff. `/show/patinfo/<iksnr>/<seqnr>/<ikscd>/diff/<date>` needs the sequence and the package, not just the registration — `Session::PI_DIFF_REGEXP` resolves it that way — and a Patinfo hangs on sequences rather than registrations, so the walk goes registration → sequence → package. That is also why it walks the live registrations rather than `app.patinfos`: only a package that still exists yields a link the page can resolve. There is no big `patinfo.rss` in the shape of the 248 MB `fachinfo.rss`; the file beside the yearly ones carries the newest fifty changes, so the subscribe icon has something to point at. On the home page the feed sits in the RSS box directly under Fachinfo-Online.

Both boxes on the home page carry the number of changes in the newest month, read from `app.rss_updates`, which the two update jobs write. Before a job has run there is no number and none is shown.

Two things had to be got right on the way. The language is read out of `descriptions` directly and not through `#de` / `#fr`: `SimpleLanguage#description` falls back to the first language present when the one asked for is missing, so a document without a French text would have filed its German history in the French feed. And the walk retires the sequence and the package as well as the registration — a sequence is also held by its ATC class, and all of those sit in `app.atc_classes`, so retiring only the registration keeps sequence, package and Patinfo alive: measured 205 MB after 300 registrations and 624 MB after 2000, which extrapolates past four gigabytes. With the two extra lines it stays flat for most of the run and peaks at 1.3 GB.

The backfill of 30.08.2026 wrote 33 files: 47 595 changes over 6427 Patinfos, 24 859 entries in German and 22 736 in French, `en` mirroring `de`. The history starts in **2017** and not earlier, because that is when the PI change log was introduced (`67db6c50`, 22.08.2017) — before that date nothing was ever written. That 2025 and 2026 hold 5717 and 8284 of the German entries against about 1500 a year before them is the other known fault showing through: until August 2026 a stumbling duplicate check in `PatinfoDocument#add_change_log_item` replaced the whole change log with the single new item, which is why 26 293 of 55 993 PI change log items were unreachable against 5154 of 73 090 on the Fachinfo side.

The yearly files stop carrying the full text, which is the point and the cost: `fachinfo-2026.rss` was 231 MB because every item embedded a rendered Fachinfo. The main `fachinfo.rss` still does, and that is the one Feedly subscribes to.

The XML is going nowhere. Feedly polls the five small channels about 290 times a day between them; those are real subscribers. `fachinfo.rss` gets two requests a day.

Adding an event needs three places, not one: the method on the state, `require` for the state class, and the name in `EVENTS` in `src/util/validator.rb`. Without the third, SBSM silently never triggers it and you get the previous page back with status 200.

### The app-down page

`ErrorDocument 500/503 /var/www/oddb.org/doc/resources/errors/appdown.html` was a filesystem path where Apache expects a URL: a value with a leading `/` is a local URL, so under `DocumentRoot /var/www/oddb.org/doc` it resolved to `…/doc/var/www/oddb.org/doc/…`, failed, and fell through to the proxy that was down. It reads `/resources/errors/appdown.html` now, which the file-exists rewrite serves off disk.

That alone was not enough for `ch.oddb.org`, which proxies to Anubis rather than to the application. **`ErrorDocument` fires only for errors Apache generates itself**; with the application down and Anubis up, Apache receives a valid response from a healthy proxy and passes it through. `ProxyErrorOverride` is what changes that, and for a while it looked like a trade rather than a fix, because measuring with `curl` showed Anubis answering **500** — a status a narrow override cannot catch and a blanket one would take from the application's genuine 500s, the ones the Search Console work is about.

The measurement was misleading. Anubis answers `curl` with its own "administrator has misconfigured Anubis" page; a **browser** during an outage gets **502**. So `ProxyErrorOverride On 502 503 504` catches exactly this case and leaves real 500s alone. The status list needs Apache 2.4.52 or later — 2.4.58 here.

`curl` cannot verify the result, which is worth knowing before trying: Anubis answers any `curl` with its own 500 page whatever `User-Agent` is sent — measured with a full Chrome user-agent while the application was up. Only a real browser gets the 502 the override converts, so this is checked in a browser during a restart and not from the shell. It is the second time Anubis' 500 has sent an investigation the wrong way; for anything else, send a Googlebot user-agent, which bypasses it, or probe `http://localhost:8012` directly.

### Do not update sbsm to 1.6.3

We run 1.6.1. 1.6.2 and 1.6.3 change 29 lines between them — ChronoLogger to Logger, hpricot to nokogiri — and neither adds anything we need. But **1.6.3 rewrote `_validate_html` and lost the sanitising in the process**: the `unless` that decided whether a tag is allowed has an empty body, so the method now only unwraps `<body>` and returns everything else verbatim. Fed `<p>ok <b>fett</b> <script>alert(1)</script> …`, 1.6.1 returns `<p>ok <b>fett</b> alert(1) link</p>` and 1.6.3 returns the input unchanged. We use it for `:html_chapter` (`HTML = [:html_chapter]` in `src/util/validator.rb`), the FI/PI chapter editor.

The one real argument for moving is that hpricot 0.8.6 is unmaintained and warns under Ruby 3.4. The way to take it is to fix `_validate_html` in sbsm first — it is our own gem.

### AdSense is off

Switched off in August 2026 in `View::GoogleAdSenseMethods` (`ENABLED = false`). The ads were not being used, but every page still carried the script from `pagead2.googlesyndication.com`, the `<ins>` block and the publisher id — and on a phone the iframe it pulled in was 504px wide, the last thing making the page scroll sideways.

The switch sits at the call site and not in the lookandfeel because `SBSM::Lookandfeel#enabled?(event, default = true)` computes `default || ENABLED.include?(event)`: with the default `true` everything is on, and removing a key from an `ENABLED` list changes nothing.

The inline style on the `<ins>` was broken twice over — `style="display:block height  #{@height}px width {@width}px"`, without colons or semicolons, and with a `{@width}` that never had its `#`. The browser dropped the whole declaration, so not even `display:block` applied.

### Posting to LinkedIn


A published post cannot be read back, and that matters more than it sounds: `commentary` is read as "Little Text Format", where `\|{}@[]()<>*_~` count as markup and are silently dropped. Our own URLs are full of underscores, so `.../rss_html/channel/price_cut.rss` went out as `.../rsshtml/channel/pricecut.rss` — a link into nowhere under a post that looked perfectly fine. `GET /rest/posts/<urn>` answers 403, so the only way to see what was published is to publish it: two forms side by side, visible to connections only, and look. `#` stays unescaped, or the hashtags stop being hashtags.
`bin/oddb_linkedin authorize`, then `bin/oddb_linkedin post --body=text.txt --image=shot.png::alt text`. Credentials live in the gitignored `etc/oddb.yml`.

Three things about this API are worth knowing before reaching for it. An image uploaded as `application/octet-stream` **vanishes silently** — 201, a valid urn, a post created, and no image; only `image/png` works. Scopes are stamped into a token when it is issued, so enabling a product or verifying the app does nothing for tokens that already exist, and they keep answering 403 with an empty body. And the `profileId` in a profile's page source is not the OpenID subject — only the `sub` from `userinfo` works as an author.

Posting is immediate; this API has no drafts, and images cannot be added to a post afterwards, which is what `delete` is for.

### Search performance

`bundle exec ruby jobs/search_performance` prints impressions, clicks, click rate and average position per property, broken down by day, query, page, country and device. Search Analytics is one of only four areas the Search Console API still covers — the Page Indexing report has none at all. Google lags two to three days, so a range ending today simply returns fewer days.

## Tests

* to run the Tests you need to do
  * bundle install
  * bundle exec ruby test/suite.rb
  * bundle exec rspec spec/parslet_spec.rb # for parsing the compositions
  * look at the index.html in the coverage directory
  
* There are some Selenium/Watir based GUI integration tests. For details on how to use them have
  a look at tests_watir.textile. By default they are run using the gem headless (this can be overrriden by
  setting the environment variable ODDB_NO_HEADLESS)

* There is test/wrk_performance.lua allows a stress test with a typical load. See test/wrk_performance.lua for details on howto run it

* A test must never write into `test/data/`. `ODDB::TEST_DATA_DIR` holds tracked fixtures and `ODDB::WORK_DIR` (`data4tests` under test) is the scratch directory — a setup that begins by wiping the latter with `rm_rf` has already said which of the two it means. `test_plugin/swissmedic.rb` and `test_plugin/swissmedic_xlsx.rb` still handed `TEST_DATA_DIR` to `SwissmedicPlugin.new` as its **archive**, the directory the plugin downloads into, and the fallout reached other test files: `test/data/xls/Packungen-latest.xlsx` is read by `test_plugin/xlsx_parser.rb`, `test_plugin/text_info.rb` and `test/integration/common.rb`, and one of the two overwrote it on every run while the other deleted it. Three tests in `swissmedic.rb` had been failing on every checkout because of it — each asserts that `Packungen-latest.xlsx` does not exist, while `setup` deleted it and copied a fixture back onto it two lines later. Note the misleading assertion message, "A previous test did not clean up": it was the test's own setup.

* `test/test_bin/` holds shell tests for the shell scripts, which `test/suite.rb` does not cover — it runs minitest against `src/`. Run them directly: `sh test/test_bin/healthcheck.sh`, `sh test/test_bin/schedule.sh`, `sh test/test_bin/pg_backup.sh`, `sh test/test_bin/install_crontab.sh`. They stub `curl`, `svc`, `svstat`, `id` and `install` on `PATH`, so none of them touches `/etc/service`, `/etc` or the running application.

## Local Documentation

* To build your local documentation do:
  * rdoc1.9 --op documentation

## Install

* sudo gem install oddb.org

## Developers

* [Zeno R.R. Davatz](https://www.linkedin.com/in/zdavatz/) 2002-present
* [Niklaus Giger](https://www.giger-electronique.ch/index.shtml) 2012-present
* [Masaomi Hatakeyama](http://www.fgcz.ch/the-center/people/hatakeyama.html) 2009-2011
* [Yasuhiro Asaka](https://www.linkedin.com/in/yasuhiro-asaka/) 2008-2009
* [Hannes Wyss](https://www.linkedin.com/in/hanneswyss/) 2002-2008

## French Translation Help

* [Herve Robin](https://www.linkedin.com/in/herobin/). Thank you Herve!

## License
### oddb.org
* GPLv3.0
### qrcode.js
* doc/resources/javascript/qrcode.js — Licensed under the [MIT license](http://www.opensource.org/licenses/mit-license.php)

## Trademarks
The word "QR Code" is registered trademark of [DENSO WAVE INCORPORATED](http://www.denso-wave.com/qrcode/faqpatent-e.html)

## Issues
For [Issues](https://github.com/zdavatz/oddb.org/issues) please open one on Github.
