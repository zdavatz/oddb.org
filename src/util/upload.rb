#!/usr/bin/env ruby
# Upload -- oddb -- 29.07.2003 -- maege@ywesee.com

module ODDB
	class Upload
		attr_reader :name, :content
		def initialize(io)
			@name = io.original_filename
			@content = io.read
		end
	end
end
