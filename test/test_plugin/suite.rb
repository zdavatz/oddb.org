#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 08.02.2011 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com

require 'test/unit'
require 'pp'
puts 8
puts File.expand_path(File.dirname(__FILE__))
puts 9
$: << File.expand_path(File.dirname(__FILE__))
require File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), 'suite.rb')
puts "Skipping bsv_xml csv_export"

# Some unit tests of ODDB work fine when called as individual files, but fail miserably
# when all other unit tests are included. 
# To work aroung this bug, we run some files separately 
buggy = [
  'swissmedic.rb',
  'text_info.rb',
  'text_info_swissmedicinfo',
]
mustBeRunSeparately = []
buggy.each{ |x| mustBeRunSeparately << File.expand_path(File.join(File.dirname(__FILE__), x)) }
                                                   
IsolatedTests.run_tests(mustBeRunSeparately)
Dir.open(File.dirname(__FILE__)) do |dir|
  dir.sort.each do |file|
    if /.*\.rb$/o.match(file)&&file!='suite.rb'
      if /bsv_xml|csv_export/.match(file)
          puts "Skipping file #{file}" if $VERBOSE
          next
      end
      if buggy.index(file)
          puts "mustBeRunSeparately #{file}" if $VERBOSE
          next
      end
        puts "require file #{file}" if $VERBOSE
        require file 
    end
  end
end
at_exit { IsolatedTests.show_results }
