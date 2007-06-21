#!/usr/bin/env ruby
# CoMarketing::TestPdfParser -- oddb.org -- 08.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'pdf_parser'

module ODDB
	module CoMarketing
		class TestPdfParser < Test::Unit::TestCase
			def setup
				path = File.expand_path('data/Co-Marketing-Praeparate_nach_Basis.pdf', 
																File.dirname(__FILE__))
				@parser = PdfParser.new(path)
			end
			def test_extract_pairs
				pairs = @parser.extract_pairs
				assert_equal(486, pairs.size)
				first = ["47358", "53442"]
				assert_equal(first, pairs.first)
				last = ["52251", "52783"]
				assert_equal(last, pairs.last)
			end
		end
	end
end
