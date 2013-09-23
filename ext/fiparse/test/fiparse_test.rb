#!/usr/bin/env ruby
# TestFiParse -- oddb -- 20.10.2003 -- rwaltert@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'fiparse'

class TestFiParse <Minitest::Test
	def test_parse_fachinfo_doc
		filename = File.expand_path('data/doc/fi_df_t2.doc', 
			File.dirname(__FILE__))
		fis = ODDB::FiParse.parse_fachinfo_doc(File.read(filename))
		assert_equal(2, fis.size)
		assert_instance_of(ODDB::FachinfoDocument, fis.first)
		assert_instance_of(ODDB::FachinfoDocument, fis.last)
	end
end
