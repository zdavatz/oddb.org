#!/usr/bin/env ruby
# TestPageFacade -- oddb -- 01.06.2004 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/page_facade'

class TestPageFacade < Test::Unit::TestCase
	def setup
		@page = ODDB::PageFacade.new(7)
	end
	def test_next
		result = @page.next
		assert_instance_of(ODDB::PageFacade, result)
		assert_equal(8, result.to_i)
		assert_equal("9", result.to_s)
	end
	def test_previous
		result = @page.previous
		assert_instance_of(ODDB::PageFacade, result)
		assert_equal(6, result.to_i)
		assert_equal("7", result.to_s)
	end
	def test_to_i
		assert_equal(7, @page.to_i)
	end
	def test_to_s
		assert_equal("8", @page.to_s) 
	end
end
