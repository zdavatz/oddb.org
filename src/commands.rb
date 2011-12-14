#!/usr/bin/env ruby
# encoding: utf-8
# CommandLoader -- oddb -- 10.04.2003 -- hwyss@ywesee.com 

dir = File.expand_path('command', File.dirname(__FILE__))
Dir.foreach(dir) { |filename|
	require('command/' + filename) if /\.rb$/u.match(filename)
}
