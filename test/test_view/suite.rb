#!/usr/bin/env ruby
# View::OneDirSuite -- oddb -- 10.02.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path(File.dirname(__FILE__))

Dir.open(File.dirname(__FILE__)) do |dir|
  dir.sort.each { |file|
	  if /.*\.rb$/o.match(file)&&file!='suite.rb'
		  require file 
	  end
  }
end
