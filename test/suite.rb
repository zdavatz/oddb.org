#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb.org -- 11.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com 
# In order to execute test/suite.rb,
# yusd and meddatad is needed to run.
$: << File.dirname(__FILE__)

dir = File.expand_path(File.dirname(__FILE__))
# Below test_suites contain tests that call each other. 
# This can result in a wrong coverage summary as shown in the example of oddbapp.rb
# Out of this reason we run test_util/suite.rb first - but this may cause other problems. Lets see.
directories =  Hash.new

  # oe next  creates additional error  Error: test_galenic_form(ODDB::TestGalenicGroup)
directories["#{dir}/../ext/suite.rb" ] = true
directories["#{dir}/test_state/suite.rb" ] = true # neither this one
directories["#{dir}/test_view/suite.rb"] = true # does not crate
directories["#{dir}/test_command/suite.rb"] = true
directories["#{dir}/test_remote/suite.rb"] = true
directories["#{dir}/test_custom/suite.rb"] = true
  # test_plugin skips bsv_xml csv_export"
directories["#{dir}/test_plugin/suite.rb"] = true
  # test_util skips ipn oddbapp session updater
directories["#{dir}/test_model/suite.rb"] = true 
directories["#{dir}/test_util/suite.rb"] = true
 

directories.each { 
  |path, res|
  puts "\n#{Time.now}: Now testing #{path} #{res}\n"
  cmd = "ruby -e\"require 'simplecov'; SimpleCov.command_name '#{File.basename(File.dirname(path), '.rb').sub('test_','')}'; SimpleCov.start; require '#{path}'\""
  result = system(cmd) 
  directories[path] = result
}
okay = true
directories.each{ 
  |path,res|
    puts "#{path} returned #{res}"
    okay = false unless res
}
puts "Overall result is #{okay}"
exit(okay ? 0 : 1)