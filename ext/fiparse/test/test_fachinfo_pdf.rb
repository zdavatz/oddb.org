#!/usr/bin/env ruby
# Fachinfo -- oddb -- 26.10.2003 -- mwalder@ywesee.com rwaltert@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require	'fachinfo_pdf'


module ODDB
	module FiParse
		class TestFachinfoPDFWriter < Test::Unit::TestCase
			def setup
				@fachinfo_pdf = FachinfoPDFWriter.new
				@parser = Rpdf2txt::Parser.new(File.read(File.expand_path("../test/data/pdf/test_file1.pdf")))
			end
			def test_send_literal_data
				@parser.extract_text(@fachinfo_pdf)
				puts @fachinfo_pdf.to_fachinfo.inspect
			end
		end
	end
end
