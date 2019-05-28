#!/usr/bin/env ruby
# encoding: utf-8
# ModelLoader -- oddb.org -- 12.01.2012 -- mhatakeyama@ywesee.com 
# ModelLoader -- oddb.org -- 03.03.2003 -- hwyss@ywesee.com 

dir = File.expand_path('model', File.dirname(__FILE__))
Dir.foreach(dir) { |filename|
	require('model/' + filename) if /\.rb$/u.match(filename)
}
