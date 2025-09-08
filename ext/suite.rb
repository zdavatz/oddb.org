#!/usr/bin/env ruby

# suite.rb -- oddb.org/ext -- 09.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org/ext -- 23.06.2011 -- mhatakeyama@ywesee.com
current_dir = __dir__

require File.expand_path(File.join(File.join(File.dirname(__FILE__), "..", "test", "helpers.rb")))
tests2run = Dir.glob("#{current_dir}/*/test/test_*.rb")
pp tests2run
runner = OddbTestRunner.new(File.dirname(__FILE__), ["meddata/test/test_drbsession.rb"])
runner.run_normal_tests(tests2run)
runner.run_isolated_tests
runner.show_results_and_exit
puts 88
