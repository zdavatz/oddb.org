#!/usr/bin/env ruby
# TestSlEntry -- oddb -- 03.03.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/slentry'
require 'model/text'
require 'date'

module ODDB
	class SlEntry
		public :adjust_types
	end
end

class TestSlEntry < Test::Unit::TestCase
	def setup
		@sl_entry = ODDB::SlEntry.new
	end
	def test_adjust_types
		values = {
			:introduction_date	=>	'01.02.2003',
			:limitation				=>	'Y',
			:limitation_points	=>	'23',
		}
		expected = {
			:introduction_date	=>	Date.new(2003, 2, 1),
			:limitation				=>	true,
			:limitation_points	=>	23,
		}
		assert_equal(expected, @sl_entry.adjust_types(values))
		values = {
			:introduction_date	=>	'01.02.2003',
			:limitation				=>	true,
			:limitation_points	=>	'23',
		}
		expected = {
			:introduction_date	=>	Date.new(2003, 2, 1),
			:limitation				=>	true,
			:limitation_points	=>	23,
		}
		assert_equal(expected, @sl_entry.adjust_types(values))
		values = {
			:limitation				=>	'',
			:limitation_points	=>	'0',
		}
		expected = {
			:limitation				=>	false,
			:limitation_points	=>	nil,
		}
		assert_equal(expected, @sl_entry.adjust_types(values))
	end
end
