#!/usr/bin/env ruby
# Swissreg::Session -- oddb.org -- 04.05.2006 -- hwyss@ywesee.com

require 'writer'
require 'util/http'

module ODDB
	module Swissreg
class Session < HttpSession
	def initialize
		super('www.swissreg.ch')
		@http.read_timeout = 120 
	end
	def extract_result_links(html)
		html.scan(%r{/servlet/ShowServlet\?regid=\d+})
	end
	def get_detail(url)
		response = get(url)
		writer = DetailWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(response.body)
		data = writer.extract_data
		if(match = /regid=(\d+)\b/.match(url))
			data.store(:srid, match[1])
		end
		data
	rescue Timeout::Error
		{}
	end
	def get_result_list(substance)
		#response = get("/all_expert.jsp")
		criteria = [
			#["ST", "1"], # Search for Patents
			["ST", "11"], # Search for 'Ergänzende Schutzzertifikate'
			["query", sprintf("GT=%s*", substance)],
			["searchhistmode", "S"],
			["count", "100"],
		]
		response = post("/servlet/AllExpertServlet", criteria)
		extract_result_links(response.body)
	rescue Timeout::Error
		[]
	end
end
	end
end
