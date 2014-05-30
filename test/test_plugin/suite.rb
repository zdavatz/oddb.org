#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 08.02.2011 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com

gem 'minitest'
require 'minitest/autorun'
require 'pp'
$: << File.expand_path(File.dirname(__FILE__))

buggy = [
  'bsv_xml.rb',
  'flockhart.rb',
  'hayes.rb',
  'invoicer.rb',
  'medical_products.rb',
  'swissmedic.rb',
  'text_info.rb',
  'text_info_swissmedicinfo',
]

require File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), 'helpers.rb')
runner = OddbTestRunner.new(File.dirname(__FILE__), buggy)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
