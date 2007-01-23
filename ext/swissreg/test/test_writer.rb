#!/usr/bin/env ruby
# Swissreg::TestWriter -- oddb.org -- 03.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'writer'

module ODDB
	module Swissreg
		class TestWriter < Test::Unit::TestCase
			def setup
				@writer = DetailWriter.new
				@formatter = ODDB::HtmlFormatter.new(@writer)
				@parser = ODDB::HtmlParser.new(@formatter)
			end
			def test_extract_data
        path = File.expand_path('data/sildenafil_detail.html', 
                                File.dirname(__FILE__))
        html = File.read(path)
				@parser.feed(html)
				expected = {
					:base_patent				=> "EP00463756",
					:base_patent_date		=> Date.new(1991, 6, 7),
					#:base_patent_srid		=> "31042544",
					:certificate_number	=> "C00463756/01",
					:expiry_date				=> Date.new(2013, 6, 21),
					:iksnrs							=> ["54642"],
					:issue_date					=> Date.new(1999, 7, 30),
					:protection_date		=> Date.new(2011, 6, 7),
					:publication_date		=> Date.new(1998, 8, 31),
					:registration_date	=> Date.new(1998, 8, 11),
				}
				assert_equal(expected, @writer.extract_data)
			end
			def test_extract_data__bag
        path = File.expand_path('data/pertactin_detail.html', 
                                File.dirname(__FILE__))
        html = File.read(path)
				@parser.feed(html)
				expected = {
					:base_patent				=> "EP00471726",
					:base_patent_date		=> Date.new(1990, 4, 26),
					#:base_patent_srid		=> "2000471726",
					:certificate_number	=> "C00471726/02",
					:expiry_date				=> Date.new(2012, 2, 25),
					:iksnrs							=> ["00595"],
					:issue_date					=> Date.new(1999, 3, 31),
					:protection_date		=> Date.new(2010, 4, 26),
					:publication_date		=> Date.new(1997, 9, 15),
					:registration_date	=> Date.new(1997, 8, 18),
				}
				assert_equal(expected, @writer.extract_data)
			end
			def test_extract_data__fr
        path = File.expand_path('data/ondansetron_detail.html', 
                                File.dirname(__FILE__))
        html = File.read(path)
				@parser.feed(html)
				expected = {
					:base_patent				=> "CH664152",
					:base_patent_date		=> Date.new(1985, 1, 25),
					:certificate_number	=> "C664152/01",
					:deletion_date			=> Date.new(2006, 8, 13),
					:expiry_date				=> Date.new(2006, 8, 13),
					:iksnrs							=> ["50709"],
					:issue_date					=> Date.new(1996, 3, 29),
					:protection_date		=> Date.new(2005, 1, 25),
					:publication_date		=> Date.new(1995, 10, 13),
					:registration_date	=> Date.new(1995, 9, 8),
				}
				assert_equal(expected, @writer.extract_data)
			end
			def test_extract_data__multiple_iksnrs
        path = File.expand_path('data/venlafaxin_detail.html', 
                                File.dirname(__FILE__))
        html = File.read(path)
				@parser.feed(html)
				expected = {
					:base_patent				=> "EP00112669",
					:base_patent_date		=> Date.new(1983, 12, 7),
					:certificate_number	=> "C00112669/01",
					:expiry_date				=> Date.new(2008, 12, 6),
					:iksnrs							=> ["52762", "52943"],
					:issue_date					=> Date.new(1996, 4, 30),
					:protection_date		=> Date.new(2003, 12, 7),
					:publication_date		=> Date.new(1996, 2, 29),
					:registration_date	=> Date.new(1995, 10, 17),
				}
				assert_equal(expected, @writer.extract_data)
			end
			def test_extract_data__swissmedic
        path = File.expand_path('data/pemetrexed_detail.html', 
                                File.dirname(__FILE__))
        html = File.read(path)
				@parser.feed(html)
				expected = {
					:base_patent				=> "EP00432677",
					:base_patent_date		=> Date.new(1990, 12, 10),
					:certificate_number	=> "C00432677/01",
					:expiry_date				=> Date.new(2015, 12, 9),
					:iksnrs							=> ["57039"],
					:issue_date					=> Date.new(2006, 12, 29),
					:protection_date		=> Date.new(2010, 12, 10),
					:publication_date		=> Date.new(2005, 4, 15),
					:registration_date	=> Date.new(2005, 3, 16),
				}
				assert_equal(expected, @writer.extract_data)
			end
			def test_extract_data__deletion
        path = File.expand_path('data/isradipin_detail.html', 
                                File.dirname(__FILE__))
        html = File.read(path)
				@parser.feed(html)
				expected = {
					:base_patent				=> "CH654836",
					:base_patent_date		=> Date.new(1980, 7, 16),
					:certificate_number	=> "C654836/01",
					:deletion_date			=> Date.new(2004, 6, 8),
					:expiry_date				=> Date.new(2004, 6, 8),
					:iksnrs							=> ["49857"],
					:issue_date					=> Date.new(1996, 6, 28),
					:protection_date		=> Date.new(2000, 7, 17),
					:publication_date		=> Date.new(1996, 3, 29),
					:registration_date	=> Date.new(1995, 12, 6),
				}
				assert_equal(expected, @writer.extract_data)
			end
		end
	end
end
