#!/usr/bin/env ruby
# TestInvoice -- oddb -- 08.10.2004 -- mwalder@ywesee.com, rwaltert@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/invoice'
require 'stub/odba'
require 'mock'

class TestInvoice < Test::Unit::TestCase
	def setup
		@invoice = ODDB::Invoice.new
	end
	def test_create_item
		item = @invoice.create_item
		assert_equal(1, @invoice.items.size)
		assert_equal(item, @invoice.item(item.oid))
	end
	def test_total
		item1 = @invoice.create_item
		item1.price = 14
		item2 = @invoice.create_item
		item2.price = 12
		assert_equal(26, @invoice.total_netto)
		assert_equal(26, @invoice.total_brutto)
		item1.vat_rate = 10
		item2.vat_rate = 10
		assert_equal(26, @invoice.total_netto)
		assert_equal(28.6, @invoice.total_brutto)
	end
	def test_payment_received
		assert_equal(false, @invoice.payment_received?)
		@invoice.payment_received!
		assert_equal(true, @invoice.payment_received?)
	end
	def test_item_by_text
		assert_equal(nil, @invoice.item_by_text('foo'))
		item = @invoice.create_item
		item.text = 'foo'
		assert_equal(item, @invoice.item_by_text('foo'))
		assert_equal(nil, @invoice.item_by_text('bar'))
	end
end
