#!/usr/bin/env ruby
# FachinfoNews -- ODDB -- 14.11.2003 -- hwyss@ywesee.com

require 'util/html_parser'

module ODDB
	module FiParse
		class FachinfoNewsWriter < NullWriter
			attr_reader :ids
			def initialize
				@ids = []
			end
			def new_linkhandler(link_handler)
				unless(link_handler.nil?)
					href = link_handler.attribute("href")
					if(match = /Info_d.cfm\?Search=([0-9]{5})/.match(href))
						@ids << match[1].to_i
					end
				end
			end
		end
	end
end
