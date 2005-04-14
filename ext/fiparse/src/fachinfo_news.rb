#!/usr/bin/env ruby
# FachinfoNews -- ODDB -- 14.11.2003 -- hwyss@ywesee.com

require 'util/html_parser'

module ODDB
	module FiParse
		class FachinfoNewsWriter < NullWriter
			@@fi_ptrn = /Monographie.aspx\?Id=([0-9A-Fa-f\-]{36}).*MonType=fi/
			attr_reader :fi_ids
			def initialize
				@fi_ids = []
			end
			def new_linkhandler(link_handler)
				unless(link_handler.nil?)
					href = link_handler.attribute("href")
					if(match = @@fi_ptrn.match(href))
						@fi_ids << match[1].to_s
				### Disable patinfo-updates for the time being.. We can't read
				### pdf-patinfos atm.
				#	elsif(match = /Info_pi_d.cfm\?Search=([0-9]{5})/.match(href))
				#		@pi_ids << match[1].to_i
					end
				end
			end
		end
	end
end
