#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com 

require 'find'
gem 'minitest'
require 'minitest/autorun'

$: << here = File.expand_path(File.dirname(__FILE__))

Find.find(here) { |file|
	if file.match(/\.rb$/) && !file.match(/suite\.rb/)
    require file
	end
}
