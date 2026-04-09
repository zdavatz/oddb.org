# oddb.org
* https://github.com/zdavatz/oddb.org

## Description
Open Drug Database for Switzerland. See the live version at http://ch.oddb.org

## Features/Problems
* **SDIF Interactions**: Drug interaction checking uses the [SDIF (Swiss Drug Interactions Finder)](https://github.com/zdavatz/sdif) SQLite database (`data/sqlite/interactions.db`). Four sources: EPha.ch curated ATC-to-ATC interactions, substance-level matches, ATC class-level keyword matching in Swissmedic FachInfo text, and CYP enzyme-mediated interactions. Each interaction shows its source (EPha.ch or Swissmedic FI) with type badge (Wirkstoff, ATC-Klasse, CYP). Route indicators (topisch, i.v., s.c., etc.) and approved combination therapy hints are displayed next to drug names. FI results display a "Gegenrichtung hat höhere Einstufung" hint when their severity is below the pair maximum across all interaction types. EPha results show the hint only for asymmetric EPha ratings between directions.
* Twitter share and mail/notify icons have been removed from drug search result lists.
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
The BSV SL (Spezialitätenliste) data is imported from FHIR NDJSON exports via `jobs/import_bsv_fhir`. The FHIR data follows the [ch-epl Implementation Guide](https://fhir.ch/ig/ch-epl/index.html). As of the Feb 2026 IG update, `productPrice` and `costShare` are nested inside the `reimbursementSL` extension on `RegulatedAuthorization` resources.

### Refdata Partner API
Refdata migrated their platform on 2026-04-01. The Partner SOAP service (used for company and doctor imports) requires an API key. Set `refdata_api_key` in `etc/oddb.yml` (or the `REFDATA_API_KEY` env var). Register at [developer.refdata.ch](https://developer.refdata.ch) to obtain a key.

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
