#!/usr/bin/env ruby
# suite.rb -- oddb -- 20.11.2002 -- hwyss@ywesee.com 

$: << File.expand_path(File.dirname(__FILE__))

Dir.foreach(File.dirname(__FILE__)) { |file|
	require file if /^test_.*\.rb$/o.match(file)
}
