#!/usr/bin/env ruby
#  -- oddb.org -- 13.04.2006 -- sfrischknecht@ywesee.com

require 'rpdf2txt/parser'
require 'pagehandler'

module ODDB
	module AnalysisParse
		def AnalysisParse.parse_pdf(path)
			pagenum = 0
			parser = Rpdf2txt::Parser.new(File.read(path))
			ph = ODDB::AnalysisParse::IndexFinder.new
			parser.page_tree.each { |page|
				ph = ph.analyze(page, pagenum)
				pagenum += 1
			}
			ph.positions
		end
	end
end
