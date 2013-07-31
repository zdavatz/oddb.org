#!/usr/bin/env ruby
# suite.rb -- oddb -- 08.09.2006 -- hwyss@ywesee.com 

require 'find'

here = File.dirname(__FILE__)

$: << File.expand_path(here)
Find.find(here) { |file|
  if /test_.*\.rb$/o.match(file) and File.file?(file)
    require File.expand_path(file)
  end
} 
