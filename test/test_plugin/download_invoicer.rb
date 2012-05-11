#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestDownloadInvoicer -- oddb.org -- 11.05.2012 -- yasaka@ywesee.com
# ODDB::TestDownloadInvoicer -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestDownloadInvoicer -- oddb.org -- 27.09.2005 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test-unit'
require 'flexmock'
require 'plugin/download_invoicer'
require 'model/invoice'

module ODDB
	class TestDownloadInvoicer < Test::Unit::TestCase
    include FlexMock::TestCase
		class FlexMock < ::FlexMock
			#undef :type
		end
		def setup
			#@app = FlexMock.new
			@app = flexmock('app')
			@plugin = DownloadInvoicer.new(@app)
		end
		def test_recent_items
			tmon = Date.today
			lmon = tmon << 1
			# last day of last month
			item1 = AbstractInvoiceItem.new
			item1.time = Time.local(tmon.year, tmon.month, 1) - (24*60*60)
			# first day of last month
			item2 = AbstractInvoiceItem.new
			item2.time = Time.local(lmon.year, lmon.month, 1)
			# last day of month before last
			item3 = AbstractInvoiceItem.new
			item3.time = Time.local(lmon.year, lmon.month, 1) - (24*60*60)
			# first day of this month
			item4 = AbstractInvoiceItem.new
			item4.time = Time.local(tmon.year, tmon.month, 1)
			items = {
				1	=>	item1,
				2	=>	item2,
				3	=>	item3,
				4	=>	item4,
			}
			slate = FlexMock.new
			slate.should_receive(:items).and_return {
				items
			}
			@app.should_receive(:slate).and_return { |name| 
				assert_equal(:download, name)
				slate
			}
			month = Date.today << 1
			day = Date.new(month.year, month.month, 1)
			assert_equal([item1, item2], @plugin.recent_items(day))
		end
		def test_group_by_user
			item1 = AbstractInvoiceItem.new
			item1.yus_name = 'name1' 
			item2 = AbstractInvoiceItem.new
			item2.yus_name = 'name1' 
			item3 = AbstractInvoiceItem.new
			item3.yus_name = 'name1' 
			item4 = AbstractInvoiceItem.new
			item4.yus_name = 'name2' 
			items = [item1, item2, item3, item4]
			groups = @plugin.group_by_user(items)
			group1 = groups['name1']
			group2 = groups['name2']
			assert_equal(3, group1.size)
			assert_equal([item1, item2, item3], group1)
			assert_equal([item4], group2)
		end
    def test_filter_paid
      invoice_item = flexmock('invoice_item', 
                      :time => Time.local(2011,2,3).to_s,
                      :type => :csv_export
                     )
      invoice = flexmock('invoice', :items => {'key' => invoice_item})
      flexmock(@app, :invoices => {'key' => invoice})
      item = flexmock('item', :time => Time.local(2011,3,3).to_s)
      assert_equal([item], @plugin.filter_paid([item]))
    end
    def test_filter_paid__empty
      invoice_item = flexmock('invoice_item', 
                      :time => Time.local(2011,2,3).to_s,
                      :type => :csv_export
                     )
      invoice = flexmock('invoice', :items => {'key' => invoice_item})
      flexmock(@app, :invoices => {'key' => invoice})
      item = flexmock('item', :time => Time.local(2011,2,3).to_s)
      assert_equal([], @plugin.filter_paid([item]))
    end

    def test_run
      invoice_item = flexmock('invoice_item', 
                      :time => Time.local(2011,2,3).to_s,
                      :type => :csv_export
                     )
      invoice = flexmock('invoice', :items => {'key' => invoice_item})
      flexmock(@app, :invoices => {'key' => invoice})
      item  = flexmock('item', 
                       :time => Time.local(2011,3,3).to_s,
                       :yus_name => 'yus_name'
                      )
      slate = flexmock('slate', :items => {'key' => item})
      flexmock(@app, :slate => slate)
      flexmock(@plugin, 
               :send_invoice   => 'ydim_id',
               :create_invoice => 'create_invoice'
              )
      assert_nil(@plugin.run(Date.new(2011,3,3)))
    end
	end
end
