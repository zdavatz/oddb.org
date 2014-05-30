#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb -- 01.07.2011 -- yasaka@ywesee.com
# suite.rb -- oddb -- 01.07.2011 -- mhatakeyama@ywesee.com 

require 'find'
gem 'minitest'
require 'minitest/autorun'

$: << here = File.expand_path(File.dirname(__FILE__))

buggy =  []
require File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), 'helpers.rb')
runner = OddbTestRunner.new(File.dirname(__FILE__), buggy)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
