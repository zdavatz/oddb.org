#!/usr/bin/env ruby
# TestFiParse -- oddb -- 20.10.2003 -- rwaltert@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'fiparse'

class TestFiParse <Minitest::Test
	def test_parse_fachinfo_docx
		puts "Missing tests for fiparse"
	end
end
