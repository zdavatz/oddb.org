#!/usr/bin/env ruby
# encoding: utf-8
# RecursiveSuite -- oddb.org -- 27.04.2011 -- mhatakeyama@ywesee.com
# OneDirSuite -- oddb -- 20.10.2003 -- mhuggler@ywesee.com

require 'find'

$: << here = File.expand_path(File.dirname(__FILE__))

Find.find(here) { |file|
	if file.match(/\.rb$/) && !file.match(/suite\.rb/)
    require file
	end
}
