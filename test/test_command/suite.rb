#!/usr/bin/env ruby
# suite.rb -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com 

require 'find'

$: << here = File.expand_path(File.dirname(__FILE__))

Find.find(here) { |file|
	if file.match(/\.rb$/) && !file.match(/suite\.rb/)
#p file
    require file
	end
}




