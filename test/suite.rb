#!/usr/bin/env ruby

# suite.rb -- oddb.org -- 11.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com
# In order to execute test/suite.rb,
# yusd and meddatad is needed to run.
$: << File.dirname(__FILE__)
require "helpers"
res = system("git checkout --quiet etc/barcode_to_text_info.yml") # needed for test/suite.rb
suites = []
suites << "test_state/suite.rb"
suites << "../ext/suite.rb"
suites << "test_view/suite.rb"
suites << "test_command/suite.rb"
suites << "test_remote/suite.rb"
suites << "test_custom/suite.rb"
suites << "test_model/suite.rb"
suites << "test_util/suite.rb"
suites << "test_plugin/suite.rb"

if $0 == __FILE__
  $stdout.sync = true
  $stderr.sync = true
  runner = OddbTestRunner.new(File.dirname(__FILE__), suites)
  runner.run_isolated_tests
  runner.show_results_and_exit
  puts "Done with show_results_and_exit"
  exit 0
end
