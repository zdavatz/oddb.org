#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org -- 29.03.2011 -- mhatakeyama@ywesee.com 

require 'find'
gem 'minitest'
require 'minitest/autorun'

$: << here = File.expand_path(File.dirname(__FILE__))

Find.find(here) { |file|
	if file.match(/\.rb$/) && !file.match(/suite\.rb/)
    require file
	end
}
# Some unit tests of ODDB work fine when called as individual files, but fail miserably
# when all other unit tests are included.
# To work aroung this bug, we run some files separately
buggy = [
  'admin/password_lost.rb',
]
mustBeRunSeparately = []
buggy.each{ |x| mustBeRunSeparately << File.expand_path(File.join(File.dirname(__FILE__), x)) }
IsolatedTests.run_tests(mustBeRunSeparately)

Dir.open(File.dirname(__FILE__)) do |dir|
  dir.sort.each do |file|
    if /.*\.rb$/o.match(file)&&file!='suite.rb'
      if buggy.index(file)
          puts "mustBeRunSeparately #{file}" # if $VERBOSE
          next
      end
        puts "require file #{file}" if $VERBOSE
        require file
    end
  end
end

