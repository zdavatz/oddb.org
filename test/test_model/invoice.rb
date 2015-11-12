#!/usr/bin/env ruby
# encoding: utf-8
# TestInvoice -- oddb -- 08.10.2004 -- mwalder@ywesee.com, rwaltert@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/invoice'

module ODDB
	class TestInvoice <Minitest::Test
    include FlexMock::TestCase
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
		def test_expired
			assert_equal(true, @invoice.expired?)
			item = @invoice.create_item
			assert_equal(true, @invoice.expired?)
			item.time = Time.now
			assert_equal(true, @invoice.expired?)
			item.expiry_time = @@today - 1
			assert_equal(true, @invoice.expired?)
			item.expiry_time = @@today
			assert_equal(false, @invoice.expired?)
		end
		def test_expired_2_items
			item = @invoice.create_item
			item2 = @invoice.create_item
			item.time = Time.now
			item.expiry_time = (Time.now + 1)
			assert_equal(false, item.expired?)
			assert_equal(true, item2.expired?)
			assert_equal(false, @invoice.expired?)
		end
		def test_deletable
			assert_equal(true, @invoice.deletable?)
		end
		def test_deletable_payment_received
			@invoice.payment_received!
			assert_equal(false, @invoice.deletable?)
		end
		def test_deletable_keep_if_unpaid
			@invoice.keep_if_unpaid = true
			assert_equal(false, @invoice.deletable?)
		end
		def test_deletable_not_expired
			item = @invoice.create_item
			item.time = Time.now
			item.expiry_time = (Time.now + 1)
			assert_equal(false, @invoice.deletable?)
		end
    def test_init
      @invoice.pointer = Persistence::Pointer.new :invoice
      @invoice.init nil
      assert_equal Persistence::Pointer.new([:invoice, @invoice.oid]),
                   @invoice.pointer
    end
    def test_max_duration
      @invoice.items.update 1 => flexmock(:duration => 2),
                            2 => flexmock(:duration => 4)
      assert_equal 4, @invoice.max_duration
      @invoice.items.update 3 => flexmock(:duration => 6)
      assert_equal 6, @invoice.max_duration
      @invoice.items.update 4 => flexmock(:duration => 5)
      assert_equal 6, @invoice.max_duration
    end
    def test_types
      @invoice.items.update 1 => flexmock(:type => :annual),
                            2 => flexmock(:type => :activation)
      assert_equal [:annual, :activation], @invoice.types
      @invoice.items.update 3 => flexmock(:type => :download)
      assert_equal [:annual, :activation, :download], @invoice.types
      @invoice.items.update 4 => flexmock(:type => :annual)
      assert_equal [:annual, :activation, :download], @invoice.types
    end
    def test_vat
      @invoice.items.update 1 => flexmock(:vat => 3),
                            2 => flexmock(:vat => 5)
      assert_equal 8, @invoice.vat
      @invoice.items.update 3 => flexmock(:vat => 7)
      assert_equal 15, @invoice.vat
    end
	end
	class TestInvoiceItem <Minitest::Test
		def setup
			@item = InvoiceItem.new
		end
		def test_total_netto_writer
			@item.vat_rate = 100/3.0
			@item.quantity = 10
			@item.total_netto = 100
			assert_equal(10, @item.price)
      assert_in_delta(100/3.0, @item.vat, 0.01)
		end
		def test_total_brutto_writer
			@item.vat_rate = 100/3.0
			@item.quantity = 1
			@item.total_brutto = 100
			assert_in_delta(75.0, @item.price, 0.01)
			assert_in_delta(25.0, @item.vat, 0.01)
		end
		def test_expired
			assert_equal(true, @item.expired?)
			assert_equal(true, @item.expired?(@@today))
			assert_equal(true, @item.expired?(Time.now))
			@item.time = Time.now
			assert_equal(true, @item.expired?)
			assert_equal(true, @item.expired?(@@today))
			assert_equal(true, @item.expired?(Time.now))
			@item.expiry_time = @@today - 1
			assert_equal(true, @item.expired?)
			assert_equal(true, @item.expired?(@@today))
			assert_equal(true, @item.expired?(Time.now))
			@item.expiry_time = @@today
			assert_equal(false, @item.expired?)
			assert_equal(false, @item.expired?(@@today))
			assert_equal(false, @item.expired?(Time.now))
		end
    def test_dup
      dupl = @item.dup
      assert @item.data.object_id != dupl.data.object_id
    end
    def test_expiry_time
      now = Time.now
      assert_equal now + 5*60*60*24, InvoiceItem.expiry_time(5, now)
    end
    def test_init
      @item.pointer = Persistence::Pointer.new [:invoice, 2], :item
      @item.init nil
      assert_equal Persistence::Pointer.new([:invoice, 2], [:item, @item.oid]),
                   @item.pointer
    end
    def test_to_s
      @item.text = 'some item text'
      assert_equal 'some item text', @item.to_s
    end
    def test_ydim_data
      now = Time.now
      expt = Time.now + 24*3600
      @item.data.store :some, :data
      @item.expiry_time = expt 
      @item.price = 100.0
      @item.quantity = 4
      @item.text = 'A Text'
      @item.time = now
      @item.unit = 'Stück'
      @item.vat_rate = 7.6
      expected = {
        :data        => { :some => :data },
        :expiry_time => expt,
        :price       => 100.0,
        :quantity    => 4,
        :text        => 'A Text',
        :time        => now,
        :unit        => 'Stück',
        :vat_rate    => 7.6,
      }
      assert_equal expected, @item.ydim_data
    end
	end
end
