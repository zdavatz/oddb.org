#!/usr/bin/env ruby
# FiParse -- oddb -- 20.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)
require 'odba'
require 'drb/drb'
require 'util/oddbconfig'
require 'fachinfo_writer'
require 'fachinfo_pdf'
require 'fachinfo_doc'
require 'indications'
require 'minifi'
require 'fachinfo_hpricot'
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
    def FiParse.extract_indications(path)
      Indications.extract(path)
    end
    def FiParse.extract_minifi(path)
      MiniFi.extract(path)
    end
		def parse_fachinfo_doc(src)
			parser = Rwv2.create_parser_from_content(src)
			handler = FachinfoTextHandler.new
			parser.set_text_handler(handler)
      parser.set_table_handler(handler.table_handler)
			parser.parse
      if(handler.writers.empty?)
        ## Product-Name was not written large enough - retry with whatever was 
        #  the largest fontsize
        handler.cutoff_fontsize = handler.max_fontsize
        parser.parse
      end
			handler.writers.collect { |wt| wt.to_fachinfo }.compact.first
		end
    def parse_fachinfo_html(src)
      if File.exist?(src)
        src = File.read src
      end
      writer = FachinfoHpricot.new
      writer.extract(Hpricot(src))
    end
		def parse_fachinfo_pdf(src)
			writer = FachinfoPDFWriter.new
			parser = Rpdf2txt::Parser.new(src, 'UTF-8')
			parser.extract_text(writer)
			writer.to_fachinfo
		end
		def parse_patinfo_html(src)
      if File.exist?(src)
        src = File.read src
      end
			writer = PatinfoHpricot.new
      writer.extract(Hpricot(src))
		end
		module_function :storage=
		module_function :parse_fachinfo_doc
		module_function :parse_fachinfo_html
		module_function :parse_fachinfo_pdf
		module_function :parse_patinfo_html
	end
end
