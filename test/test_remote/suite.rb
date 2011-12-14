#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb -- 01.07.2011 -- mhatakeyama@ywesee.com 

require 'find'

$: << here = File.expand_path(File.dirname(__FILE__))

Find.find(here) { |file|
	if file.match(/\.rb$/) && !file.match(/suite\.rb/)
#p file
    require file
	end
}
