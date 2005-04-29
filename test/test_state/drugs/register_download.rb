#!/usr/bin/env ruby
# State::Drugs::TestRegisterDownload -- ODDB -- 29.04.2005 -- hwyss@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/drugs/register_download'

module ODDB
	module State
		module Drugs
class TestRegisterDownload < Test::Unit::TestCase
	def test_price
		assert_equal(0, RegisterDownload.price(0))
		assert_equal(3.50, RegisterDownload.price(1))
		assert_equal(3.50, RegisterDownload.price(100))
		assert_equal(4.50, RegisterDownload.price(101))
		assert_equal(4.50, RegisterDownload.price(200))
		assert_equal(5.50, RegisterDownload.price(201))
		assert_equal(5.50, RegisterDownload.price(300))
	end
end
		end
	end
end
