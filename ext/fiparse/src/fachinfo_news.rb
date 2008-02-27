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
          if(id = FachinfoNewsWriter.extract_fachinfo_id(href))
            @fi_ids << id
          end
				end
			end
      def FachinfoNewsWriter.extract_fachinfo_id(href)
        if(match = @@fi_ptrn.match(href))
          match[1].to_s
        end
      end
		end
	end
end
