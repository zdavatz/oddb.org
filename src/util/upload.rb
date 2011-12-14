#!/usr/bin/env ruby
# encoding: utf-8
# Upload -- oddb -- 29.07.2003 -- mhuggler@ywesee.com

module ODDB
	class Upload
		attr_reader :name, :content
		def initialize(io)
			@name = io.original_filename
			@content = io.read
		end
	end
end
