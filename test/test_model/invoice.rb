#!/usr/bin/env ruby
# TestInvoice -- oddb -- 08.10.2004 -- mwalder@ywesee.com, rwaltert@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/invoice'
require 'mock'

class TestInvoice < Test::Unit::TestCase
	def setup
		@invoice = ODDB::Invoice.new(:patinfo)
	end
	def test_create_item
		@invoice.create_item
		assert_equal(1 ,@invoice.items.size)
	end
end
