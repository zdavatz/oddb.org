#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb.org -- 11.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com 
# In order to execute test/suite.rb,
# yusd and meddatad is needed to run.
$: << File.dirname(__FILE__)


# Some unit tests of ODDB work fine when called as individual files, but fail miserably
# when all other unit tests are included. 
# To work aroung this bug, we run some files separately 

module IsolatedTests
  @@directories =  Hash.new

  def IsolatedTests.run_tests(files)
    files.each { 
      |path, res|
      rubyExe = `which ruby`.chomp
      puts "\n#{Time.now}: Now testing #{path} #{res} using #{rubyExe}\n"
      base = File.basename(path).sub('.rb', '')
      group_name = File.basename(File.dirname(path), '.rb').sub('test_','')
      group_name += ':'+base unless base.eql?('suite')
      cmd = "#{rubyExe} -e\"require 'simplecov'; SimpleCov.command_name '#{group_name}'; SimpleCov.start; require '#{path}'\""
      result = system(cmd) 
      @@directories[path] = result
    }
  end
  def IsolatedTests.show_results
    okay = true
    @@directories.each{ 
      |path,res|
        puts "#{path} returned #{res}"
        okay = false unless res
    }
    puts "Overall result is #{okay}"
    okay
  end

end

dir = File.expand_path(File.dirname(__FILE__))

# Below test_suites contain tests that call each other. 
# This can result in a wrong coverage summary as shown in the example of oddbapp.rb
# Out of this reason we run test_util/suite.rb first - but this may cause other problems. Lets see.
suites =  []
  # oe next  creates additional error  Error: test_galenic_form(ODDB::TestGalenicGroup)
suites << "#{dir}/../ext/suite.rb" 
suites << "#{dir}/test_state/suite.rb"  # neither this one
suites << "#{dir}/test_view/suite.rb" # does not crate
suites << "#{dir}/test_command/suite.rb"
suites << "#{dir}/test_remote/suite.rb"
suites << "#{dir}/test_custom/suite.rb"
  # test_plugin skips bsv_xml csv_export"
suites << "#{dir}/test_plugin/suite.rb"
  # test_util skips ipn oddbapp session updater
suites << "#{dir}/test_model/suite.rb" 
suites << "#{dir}/test_util/suite.rb"

if $0 == __FILE__
  puts suites
  if true
    IsolatedTests.run_tests(suites)
    IsolatedTests.show_results
  else
#  suites.each{ |suite| require suite }
#  exit(IsolatedTests.show_results ? 0 : 1)
  end
end