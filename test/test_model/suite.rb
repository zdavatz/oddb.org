#!/usr/bin/env ruby

# RecursiveSuite -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# RecursiveSuite -- oddb.org -- 27.04.2011 -- mhatakeyama@ywesee.com
# OneDirSuite -- oddb -- 20.10.2003 -- mhuggler@ywesee.com
$: << File.expand_path("..", File.dirname(__FILE__))
require "stub/odba"
must_be_run_separately = ["package.rb"]
require File.join(File.expand_path(File.dirname(__FILE__, 2)), "helpers.rb")
runner = OddbTestRunner.new(File.dirname(__FILE__), must_be_run_separately)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
