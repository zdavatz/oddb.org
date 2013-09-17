#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 08.02.2011 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com

require 'test/unit'
require 'pp'
puts File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(File.dirname(__FILE__))
require File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), 'suite.rb')

# Some unit tests of ODDB work fine when called as individual files, but fail miserably
# when all other unit tests are included. 
# To work aroung this bug, we run some files separately 
buggy = [
  'swissmedic.rb',               # 66 tests, 142 assertions, 0 failures, 0 errors,  2 skips on 2013-09-04
  'text_info.rb',                # 30 tests,  45 assertions, 0 failures, 0 errors, 10 skips on 2013-09-04
  'text_info_swissmedicinfo',    # 10 tests,  11 assertions, 1 failures, 0 errors,  0 skips on 2013-09-04
]
mustBeRunSeparately = []
buggy.each{ |x| mustBeRunSeparately << File.expand_path(File.join(File.dirname(__FILE__), x)) }
IsolatedTests.run_tests(mustBeRunSeparately)

Dir.open(File.dirname(__FILE__)) do |dir|
  dir.sort.each do |file|
    if /.*\.rb$/o.match(file)&&file!='suite.rb'
      if buggy.index(file)
          puts "mustBeRunSeparately #{file}" if $VERBOSE
          next
      end
        puts "require file #{file}" if $VERBOSE
        require file 
    end
  end
end
