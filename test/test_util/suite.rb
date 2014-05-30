#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 09.04.2012 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com
require 'simplecov'
SimpleCov.start


gem 'minitest'
require 'minitest/autorun'
$: << File.expand_path(File.dirname(__FILE__))

buggy = [
  'oddbapp.rb',
  'oddbapp_2.rb',
]

require File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), 'helpers.rb')
runner = OddbTestRunner.new(File.dirname(__FILE__), buggy)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
