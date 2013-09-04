#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb -- 09.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb -- 03.03.2011 -- mhatakeyama@ywesee.com 

require 'find'
require 'test/unit'

$: << here = File.expand_path(File.dirname(__FILE__))

Find.find(here) { |file|
	if file.match(/\.rb$/) && !file.match(/suite\.rb/)
    require file
	end
}
