#!/usr/bin/env ruby
# States -- oddb -- 22.10.2002 -- hwyss@ywesee.com 

Dir.entries(File.dirname(__FILE__)).each { |file| 
	if /^[a-z_]+\.rb$/.match(file)
		#print file
		#print ":"
		#puts 
		require('state/' << file)
	end
}
