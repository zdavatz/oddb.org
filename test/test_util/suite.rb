#!/usr/bin/env ruby
# Some tests must be run in a separate run, as they either
# create too many threads (limit is 100)
# or use different web mocking
must_be_run_isolated = [
  "config.rb",
  "http.rb",
  # Laeuft einzeln gruen, im gemeinsamen Durchlauf nicht: ConfigStub aus
  # test/stub/config.rb wird dort von einer anderen Datei ueberschrieben,
  # und TestGoogleSearchConsoleAuth bekommt
  # "undefined method 'gsc_service_account_email='" (20.11.2026).
  "indexing_check.rb",
  "ipn.rb",
  "latest.rb",
  "oddbapp.rb",
  "oddbapp_2.rb",
  "oddbapp_3.rb",
  "oddbapp_rss.rb",
  "persistence.rb",
  "resilient_loop.rb",
  "session.rb"
]

require File.join(File.expand_path(File.dirname(__FILE__, 2)), "helpers.rb")
runner = OddbTestRunner.new(File.dirname(__FILE__), must_be_run_isolated)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
