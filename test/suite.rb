#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb.org -- 11.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com 
# In order to execute test/suite.rb,
# yusd and meddatad is needed to run.
require 'simplecov'
SimpleCov.start
SimpleCov.start do
  add_filter "/test/"
end

$: << File.dirname(__FILE__)

dir = File.expand_path(File.dirname(__FILE__))
# Below test_suites contain tests that call each other. 
# This can result in a wrong coverage summary as shown in the example of oddbapp.rb
# Out of this reason we run test_util/suite.rb first - but this may cause other problems. Lets see.
directories = [
  
  "#{dir}/../ext/suite.rb",
  "#{dir}/test_model/suite.rb", 
  "#{dir}/test_state/suite.rb",
  "#{dir}/test_view/suite.rb",
  "#{dir}/test_command/suite.rb",
  "#{dir}/test_remote/suite.rb",
  "#{dir}/test_custom/suite.rb",

  # test_plugin skips bsv_xml csv_export"
  "#{dir}/test_plugin/suite.rb",
  # test_util skips ipn oddbapp session updater
  "#{dir}/test_util/suite.rb",
]

directories.each_with_index { |path, i|
  puts "\n#{Time.now}: Now testing #{path}\n"
  require path
}
