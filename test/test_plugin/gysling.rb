#!/usr/bin/env ruby
# TestGyslingPlugin -- oddb -- 13.09.2004 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/gysling'
require 'csv'
require 'mock'

class TestGyslingPlugin < Test::Unit::TestCase
	def setup
		line_arrays = [
			["Substrate 1 Nervensystem", "", "", "", "", "", "", ""],
			["Wirkstoffe", "1A2", "2A6", "2C19", "2C8/9", "2D6", "2E1", "3A4/5/7"],
			["Acetylsalicyls\344ure", "", "", "", "1", "", "1", "1"],
			["Citalopram", "\240", "", "1", "", "1", "", "1"],
			["Isradipin", "\240", "\240", "\240", "\240", "\240", "\240", "1"],
			["Substrate:  Hormone, Hormonantagonisten, Antidiabetika", "", "", "", "", "", "", ""],
			["Methylprednisolon", "\240", "\240", "\240", "\240", "\240", "\240", "1"],
			["CYP-Hemmer", "", "", "", "", "", "", ""],
			["Clarithromycin", "\240", "\240", "\240", "\240", "\240", "\240", "11"],
			["CYP-Induktoren", "", "", "", "", "", "", ""],
			["Aminoglutethimid", "\240", "\240", "11", "11", "", "", ""],
		]
		@writer = ODDB::Interaction::GyslingWriter.new(line_arrays)
	end
	def test_extract_data
		cytochromes = @writer.extract_data
		assert_equal(cytochromes["1A2"].substrates.size, 0)
		assert_equal(cytochromes["1A2"].inducers.size, 0)
		assert_equal(cytochromes["1A2"].inhibitors.size, 0)
		
		assert_equal(cytochromes["2A6"].substrates.size, 0)
		assert_equal(cytochromes["2A6"].inducers.size, 0)
		assert_equal(cytochromes["2A6"].inhibitors.size, 0)
		
		assert_equal(cytochromes["2C19"].substrates.size, 1)
		assert_equal(cytochromes["2C19"].inducers.size, 1)
		assert_equal(cytochromes["2C19"].inhibitors.size, 0)
		
		assert_equal(cytochromes["2C8"].substrates.size, 1)
		assert_equal(cytochromes["2C8"].inducers.size, 1)
		assert_equal(cytochromes["2C8"].inhibitors.size, 0)
		assert_equal(cytochromes["2C9"].substrates.size, 1)
		assert_equal(cytochromes["2C9"].inducers.size, 1)
		assert_equal(cytochromes["2C9"].inhibitors.size, 0)
		
		assert_equal(cytochromes["2D6"].substrates.size, 1)
		assert_equal(cytochromes["2D6"].inducers.size, 0)
		assert_equal(cytochromes["2D6"].inhibitors.size, 0)
		
		assert_equal(cytochromes["2E1"].substrates.size, 1)
		assert_equal(cytochromes["2E1"].inducers.size, 0)
		assert_equal(cytochromes["2E1"].inhibitors.size, 0)
		
		assert_equal(cytochromes["3A4"].substrates.size, 4)
		assert_equal(cytochromes["3A4"].inducers.size, 0)
		assert_equal(cytochromes["3A4"].inhibitors.size, 1)
		assert_equal(cytochromes["3A5-7"].substrates.size, 4)
		assert_equal(cytochromes["3A5-7"].inducers.size, 0)
		assert_equal(cytochromes["3A5-7"].inhibitors.size, 1)
	end
end
