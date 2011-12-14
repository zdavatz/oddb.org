#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 20.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path(File.dirname(__FILE__))

Dir.foreach(File.dirname(__FILE__)) { |file|
	if /.*\.rb$/o.match(file)&&file!='suite.rb'
		require file 
	end
}
