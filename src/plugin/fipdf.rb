#!/usr/bin/env ruby
# encoding: utf-8
# FiPDFExporter -- ODDB -- 13.02.2004 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'util/oddbconfig'
require 'util/searchterms'
require 'drb'
require 'model/fachinfo'
require 'delegate'

module ODDB
	class FiPDFExporter < Plugin
		WRITER = DRbObject.new(nil, FIPDF_URI)
		PDF_PATH = File.expand_path('downloads', ARCHIVE_PATH)
		def run
			write_pdf
		end
		def write_pdf(language = :de, path = nil, fachinfos = nil)
			path ||= File.expand_path('fachinfos.pdf', PDF_PATH)
			fachinfos ||= @app.fachinfos.values
      ids = fachinfos.collect do |fi| fi.odba_id end
      WRITER.write_pdf ids, language, path
		end
	end
end
