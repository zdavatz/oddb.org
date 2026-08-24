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

**Note:** The `fiparse` daemon (DRb on port 10002) runs as a separate process managed by daemontools (`/etc/service/fiparse`). After making code changes to `ext/fiparse/src/`, restart the daemon with `sudo svc -h /etc/service/fiparse` for changes to take effect.

### Fachinfo Table Rendering
Tables from swissmedicinfo are parsed by `detect_table?` in `ext/fiparse/src/textinfo_html_parser.rb`. Tables with percentage-width styles are rendered as preformatted text; others are rendered as HTML tables with proper `colspan`/`rowspan` support. The view (`src/view/chapter.rb`) only emits `colspan`/`rowspan` attributes when > 1 to avoid invalid `colspan="0"` in the output.

### Swiyu Login
The app uses [Swiyu](https://www.eid.admin.ch/en/swiyu) wallet-based authentication (OID4VP). After exceeding the 5-search query limit, users are prompted to log in. The login flow passes a `return_url` parameter so users are redirected back to their last search result after authentication.

### BSV FHIR Import
The BSV SL (Spezialitätenliste) data is imported from FHIR NDJSON exports. As of June 2026, `jobs/import_bsv` uses the FHIR NDJSON source by default (mirroring oddb2xml); pass `--no-fhir` to fall back to the legacy `XMLPublications.zip` import. The dedicated `jobs/import_bsv_fhir` job remains as an explicit alias. The FHIR data follows the [ch-epl Implementation Guide](https://fhir.ch/ig/ch-epl/index.html). As of the Feb 2026 IG update, `productPrice` and `costShare` are nested inside the `reimbursementSL` extension on `RegulatedAuthorization` resources. As of April 2026, the import downloads three per-language NDJSON files directly (`foph-sl-export-latest-{de,fr,it}.ndjson`) so French and Italian product names and limitation texts are populated alongside the German source. As of June 2026, change detection no longer re-downloads the ~93 MB files every run: a cheap HTTP HEAD reads each `-latest-` file's `Last-Modified` date, derives the immutable dated link (`foph-sl-export-<YYYYMMDD>-<lang>.ndjson`), and saves it in a `<file>.source` sidecar — the download and reparse are skipped entirely while the date is unchanged. As of July 2026, the SL-introduction / price-change flags that drive the med-drugs xls export (`OuwerkerkPlugin`, sent to just-medical) are computed correctly again: `fix_flags_with_rss_logic_for` now reads the previous price via `pack.price_public(1)` (the new price has already been stored at index 0 by the time it runs), mirroring the RSS feed logic. Previously it read the just-stored current price, so new Kassenzulässigkeiten (`:sl_entry`), price cuts and price rises were silently dropped from the export while `sl_introduction.rss` still listed them. As of August 2026 limitation texts are imported again: BAG no longer inlines them in a `limitationText` sub-extension but publishes them as separate `ClinicalUseDefinition` resources referenced via `limitationIndication`, so the importer now follows that reference. Without it every limitation was skipped and only 16 legacy texts remained in the database while the export carried some 6300. The referenced resource id is the LimitationCode (e.g. `ABEVMY.07`), which BAG confirms is limitation-specific and stable across publications; the FR/IT exports use the same ids with translated text. The BAG "IndC" code (`indicationCode`, e.g. `22064.07`) is rendered as the subheading of the limitation text.

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
About 25000 requests returned 500 in August 2026, on exactly the pages Google crawls. Four fixes cover roughly 24500 of them. The largest by far was every `/diff/` change-log page: Diffy tags the external `diff` output ASCII-8BIT when it is not valid UTF-8, the html formatter then re-diffs character by character and splits multi-byte sequences into single bytes, and writing those to a Tempfile transcodes and raises — but only because `config.ru` sets `Encoding.default_internal`, which is why it never reproduced in tests. `View::Drugs.utf8_diff` re-tags the text and scrubs only the genuinely invalid bytes. The rest were broken ODBA references on patinfo and fachinfo pages, where `ODBA::Stub#is_a?` answers from the *declared* class without resolving the stub, so a guard written as `is_a? Text::Chapter` passed and the next call raised; the guards use `respond_to?`, which does resolve. A related trap: `unless document&.empty?` lets a *nil* document through, because `PatinfoDocument#empty?` returns nil and so does `nil&.empty?`. The same family turned up in `view/admin/sequence.rb`, where the guard needs care: the obvious `respond_to?(:de)` would reject every real substance, since `SimpleLanguage` defines no `de`/`fr`/`it` methods and instead routes any two-letter symbol through `method_missing` with a matching `respond_to?` override. Be aware these failures are intermittent — the same URL can answer 500 and then 200 minutes later without a restart, because whether an ODBA stub resolves depends on cache and connection state, so a single URL is never proof that a fix worked. Worth knowing that the single biggest cause was not code — the `google_crawler` process serving Googlebot on port 8112 was dead for 9.7 days while `svstat` still reported it up.

### Cron
`/etc/crontab` and every script it calls are versioned as `etc/crontab` and `bin/oddb_cron`. Install both with `sudo bin/install_crontab --apply`, which backs up what it replaces; installing the crontab alone breaks every job, because it calls `/usr/local/sbin/oddb_cron`. One line covers all nine ch.oddb.org jobs — `* * * * * zdavatz /usr/local/sbin/oddb_cron schedule` runs every minute and the times live in a table inside the script (`oddb_cron schedule-list`). The certbot and backup lines stay separate because cron takes one user per line and those run as root; the install step makes the script root-owned, which also closes a pre-existing hole where cron ran a zdavatz-owned backup script as root. Job output goes to `log/cron/<job>-<YYYY-MM>.log` instead of the `>/dev/null 2>&1` the old lines carried — a failing import used to look exactly like a successful one.

### Apache vhosts
Apache reads `/etc/apache2/sites-available/oddb-ssl.conf`, not the repo copy in `etc/20_oddb.org.rack.conf` — the two had drifted, so both need changing. A catch-all `*:80` vhost must stay first: Apache serves the first `*:80` vhost for any unmatched Host header, and that used to be `sl_errors.oddb.org`, so `http://oddb.org/` and bot probes with mangled hosts got a directory listing of `doc/sl_errors`. Note that `Redirect /` appends the remaining path, so a target without a trailing slash concatenates — `http://generika.cc/de/generika/` redirected to `https://generika.ccde/generika/`; use `RedirectMatch` where the path should be dropped and a trailing slash where it should be kept. The certificate covers only the names it lists, so a vhost cannot fix a handshake that never completes; expand it with `certbot certonly --standalone --expand`. Finally, Anubis (bot protection, `:443` → `localhost:9000` → `8012`) answers `curl` with HTTP 500 while serving browsers normally, so a 500 from `https://ch.oddb.org/` says nothing about the application.

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
