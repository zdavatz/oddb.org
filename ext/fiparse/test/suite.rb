#!/usr/bin/env ruby
# suite.rb -- oddb -- 08.09.2006 -- hwyss@ywesee.com

require "find"

here = File.dirname(__FILE__)

$: << File.expand_path(here)
Find.find(here) { |file|
  require_relative("update_test_html_files.rb")
  if /test_.*\.rb$/o.match(file) && File.file?(file)
    next if /update_test_html_files/.match(file)
    require File.expand_path(file)
  end
}
