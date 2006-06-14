#!/usr/bin/env ruby
# CoMarketing -- oddb.org -- 09.05.2006 -- hwyss@ywesee.com

require 'pdf_parser'

module ODDB
	module CoMarketing
		def CoMarketing.get_pairs(url)
			PdfParser.new(url).extract_pairs
		end
	end
end
