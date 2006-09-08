#!/usr/bin/env ruby
# FiParse -- oddb -- 20.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)
require 'odba'
require 'drb/drb'
require 'util/oddbconfig'
require 'fachinfo_writer'
require 'fachinfo_pdf'
require 'fachinfo_html'
require 'fachinfo_pdf'
require 'fachinfo_news'
#require 'fachinfo_doc'
require 'patinfo_hpricot'
require 'rpdf2txt/parser'

module ODDB
	class FachinfoDocument
		def initialize
		end
	end
	module FiParse
		def storage=(storage)
			ODBA.storage = storage
		end
		def parse_fachinfo_doc(src)
			parser = Rwv2.create_parser_from_content(src)
			handler = FachinfoTextHandler.new
			parser.set_text_handler(handler)
			parser.parse
			handler.writers.collect { |wt| wt.to_fachinfo }
		end
		def parse_fachinfo_html(src)
			writer = FachinfoHtmlWriter.new
			formatter = HtmlFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(src)
			unless(writer.pseudo?)
				writer.to_fachinfo 
			end
		end
		def parse_fachinfo_pdf(src)
			writer = FachinfoPDFWriter.new
			parser = Rpdf2txt::Parser.new(src)
			parser.extract_text(writer)
			writer.to_fachinfo
		end
		def parse_fachinfo_news(src)
			writer = FachinfoNewsWriter.new
			formatter = HtmlFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(src)
			writer.fi_ids.compact
		end
		def parse_patinfo_html(src)
			writer = PatinfoHpricot.new
      writer.extract(Hpricot(src))
		end
		module_function :storage=
		module_function :parse_fachinfo_doc
		module_function :parse_fachinfo_pdf
		module_function :parse_fachinfo_html
		module_function :parse_fachinfo_news
		module_function :parse_patinfo_html
	end
end
