#!/usr/bin/env ruby
# encoding: utf-8
# RecursiveSuite -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# RecursiveSuite -- oddb.org -- 27.04.2011 -- mhatakeyama@ywesee.com
# OneDirSuite -- oddb -- 20.10.2003 -- mhuggler@ywesee.com
buggy =  []
require File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), 'helpers.rb')
runner = OddbTestRunner.new(File.dirname(__FILE__), buggy)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
