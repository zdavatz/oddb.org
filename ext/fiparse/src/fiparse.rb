#!/usr/bin/env ruby
# FiParse -- oddb -- 20.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'drb/drb'
require 'util/oddbconfig'
require 'fachinfo_writer'
require 'fachinfo_html'
require 'fachinfo_news'
require 'fachinfo_doc'
require 'patinfo_html'

module ODDB
	module FiParse
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
			writer.to_fachinfo
		end
		def parse_fachinfo_news(src)
			writer = FachinfoNewsWriter.new
			formatter = HtmlFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(src)
			writer.ids.compact
		end
		def parse_patinfo_html(src)
			writer = PatinfoHtmlWriter.new
			formatter = HtmlFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(src)
			writer.to_patinfo
		end
		module_function :parse_fachinfo_doc
		module_function :parse_fachinfo_html
		module_function :parse_fachinfo_news
		module_function :parse_patinfo_html
	end
end

#trap("HUP") { puts "caught HUP signal, shutting down\n"; exit }
#trap("TERM") { puts "caught TERM signal, shutting down\n"; exit }

DRb.start_service(ODDB::FIPARSE_URI, ODDB::FiParse)

$0 = "Oddb (FiParse)"

DRb.thread.join
