#!/usr/bin/env ruby
# encoding: utf-8
# TestPatinfoInvoicer -- oddb -- 09.04.2012 -- yasaka@ywesee.com
# TestPatinfoInvoicer -- oddb -- 25.02.2011 -- mhatakeyama@ywesee.com
# TestPatinfoInvoicer -- oddb -- 16.08.2005 -- jlang@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'stub/odba'
require 'plugin/patinfo_invoicer'
require 'model/invoice'

module ODDB
	class TestPatinfoInvoicer <Minitest::Test
    include FlexMock::TestCase
		class FlexMock < ::FlexMock
			#undef :type
		end
    @@now = Time.now.round

		def setup
			@app = FlexMock.new
			@plugin = PatinfoInvoicer.new(@app)
		end
		def test_adjust_annual_fee
			item1 = AbstractInvoiceItem.new
			item1.type = :annual_fee
			item1.time = Time.local(2005, 12, 1, 18, 26, 42)
			company = FlexMock.new 'company'
			company.should_receive(:invoice_date).with(:patinfo).and_return { Date.new(2006) }
			company.should_receive(:limit_invoice_duration).and_return false
			company.should_receive(:patinfo_price).and_return { 100 }
			@plugin.adjust_annual_fee(company, [item1])
			assert_equal(31.0/365.0, item1.quantity)
		end
		def test_adjust_annual_fee__2
			item1 = AbstractInvoiceItem.new
			item1.type = :annual_fee
			item1.time = Time.local(2005, 12, 2, 18, 26, 42)
			company = FlexMock.new 'company'
			company.should_receive(:invoice_date).with(:patinfo).and_return { Date.new(2006) }
			company.should_receive(:limit_invoice_duration).and_return false
			company.should_receive(:patinfo_price).and_return { 100 }
			@plugin.adjust_annual_fee(company, [item1])
			assert_equal(395.0/365.0, item1.quantity)
		end
		def test_filter_paid
			ptr1 = FlexMock.new
			ptr2 = FlexMock.new
			ptr3 = FlexMock.new
			ptr4 = FlexMock.new
			ptr1.should_receive(:resolve).and_return { } # disables the neighborhood_names check
			ptr2.should_receive(:resolve).and_return { }
			ptr3.should_receive(:resolve).and_return { }
			ptr4.should_receive(:resolve).and_return { }
			day = Date.today - 1
			## Item that has been paid more than a year ago
			## (inv1) - should be in new invoice
			item1 = AbstractInvoiceItem.new
			item1.item_pointer = ptr1
			item1.text = '11111 11'
			item1.type = :annual_fee
			item1.time = Time.local(day.year, day.month, 
				day.day, 10, 32)
			## Item that has never before been uploaded
			## should be in new invoice
			item2 = AbstractInvoiceItem.new
			item2.item_pointer = ptr2
			item2.text = '22222 22'
			item2.type = :annual_fee
			item2.time = Time.local(day.year, day.month, 
				day.day, 10, 32)
			## Item that is already once in new invoice
			## (item1) - should not be in new invoice
			item3 = AbstractInvoiceItem.new
			item3.item_pointer = ptr3
			item3.text = '11111 11'
			item3.type = :annual_fee
			item3.time = Time.local(day.year, day.month, 
				day.day, 16, 23)
			## Item that has been paid less than a year ago
			## (inv2) - should not be in new invoice
			item4 = AbstractInvoiceItem.new
			item4.item_pointer = ptr4
			item4.text = '33333 33'
			item4.type = :annual_fee
			item4.time = Time.local(day.year, day.month, 
				day.day, 16, 23)
			items = [item1, item2, item3, item4]

			inv1 = FlexMock.new
			inv1.should_receive(:items).and_return {
				itm1 = FlexMock.new
				itm1.should_receive(:expired?).and_return { true }
				itm1.should_receive(:type).and_return { :annual_fee }
				itm1.should_receive(:item_pointer).and_return { 'model 1' }
				itm1.should_receive(:text).and_return { '11111 11' }
				itm2 = FlexMock.new
				itm2.should_receive(:expired?).and_return { false }
				itm2.should_receive(:type).and_return { :processing }
				itm2.should_receive(:item_pointer).and_return { 'model 1' }
				itm2.should_receive(:text).and_return { '11111 11' }
				{1 => itm1, 2 => itm2}
			}
			inv2 = FlexMock.new
			inv2.should_receive(:items).and_return {
				itm1 = FlexMock.new
				itm1.should_receive(:expired?).and_return { false }
				itm1.should_receive(:type).and_return { :annual_fee }
				itm1.should_receive(:item_pointer).and_return { 'model 3' }
				itm1.should_receive(:text).and_return { '33333 33' }
				{1 => itm1}
			}
			inv3 = FlexMock.new
			inv3.should_receive(:items).and_return {
				itm1 = FlexMock.new
				itm1.should_receive(:expired?).and_return { false }
				itm1.should_receive(:type).and_return { :annual_fee }
				itm1.should_receive(:item_pointer).and_return { 'model 4' }
				itm1.should_receive(:text).and_return { '44444 44' }
				{1 => itm1}
			}
			@app.should_receive(:invoices).and_return { 
				{
					1 => inv1, 
					2 => inv2,
					3 => inv3,
				}
			}
			expected = [item1, item2]
			assert_equal(expected, @plugin.filter_paid(items))
		end
		def test_recent_items
			ptr = FlexMock.new
			ptr.should_receive(:resolve).and_return { true }
			today = Date.new(2011,3,29)
			item1 = AbstractInvoiceItem.new
			item1.item_pointer = ptr
			item1.time = Time.local(today.year, today.month,
				today.day) - (24*60*60)
			item1.text = '12345 01'
			item2 = AbstractInvoiceItem.new
			item2.item_pointer = ptr
			item2.time = Time.local(today.year, today.month,
				today.day, 23, 59, 59) - (2*24*60*60)
			item2.text = '12345 02'
			item3 = AbstractInvoiceItem.new
			item3.item_pointer = ptr
			item3.time = Time.local(today.year, today.month,
				today.day, 23, 59, 59) - (24*60*60)
			item3.text = '12345 03'
			item4 = AbstractInvoiceItem.new
			item4.item_pointer = ptr
			item4.time = Time.local(today.year, today.month,
				today.day)
			item4.text = '12345 04'
			item5 = AbstractInvoiceItem.new
			item5.item_pointer = ptr
			item5.time = Time.local(today.year, today.month,
				today.day, 23, 59, 58) - (24*60*60)
			item5.text = '12345 03'
			items = {
				1	=>	item1,
				2	=>	item2,
				3	=>	item3,
				4	=>	item4,
				5	=>	item5,
			}
			slate = FlexMock.new
			slate.should_receive(:items).and_return {
				items
			}
			@app.should_receive(:slate).and_return { |name| 
				assert_equal(:patinfo, name)
				slate
			}
			@app.should_receive(:active_pdf_patinfos).and_return {
				{
					'12345_01.pdf' => 1, '12345_02.12347435.pdf' => 1,
					'12345_03.pdf' => 1, '12345_04.e1718.pdf' => 1, 
															 '12345_03.12345654.pdf' => 1,
				}	
			}
			assert_equal(2, @plugin.recent_items(today - 1).size)
			assert_equal([item3,item1], @plugin.recent_items(today - 1))
		end
		def test_group_by_company
			old_invoice = FlexMock.new
			company1 = FlexMock.new
			company1.should_receive(:invoice_date).with(:patinfo).and_return { nil }
			company1.should_receive(:patinfo_price).and_return { nil }
			company2 = FlexMock.new
			company2.should_receive(:invoice_date).with(:patinfo).and_return { nil }
			company2.should_receive(:patinfo_price).and_return { nil }
			@app.should_receive(:invoices).and_return { { 1 => old_invoice } }
			old_item = FlexMock.new
			old_invoice.should_receive(:items).and_return { { 1 => old_item } }
			old_item.should_receive(:type).and_return { :annual_fee }
			item_pointer = FlexMock.new
			old_item.should_receive(:item_pointer).and_return { item_pointer }
			sequence = FlexMock.new
      sequence.should_receive(:is_a?).with(Sequence).and_return true
			item_pointer.should_receive(:resolve).and_return { sequence }
			sequence.should_receive(:company).and_return { company2 }
			pointer = FlexMock.new
			time = @@now
			item1 = AbstractInvoiceItem.new
			item1.yus_name = 'user1'
			item1.item_pointer = pointer
			item1.text = '11111 11'
			item1.time = time
			item2 = AbstractInvoiceItem.new
			item2.yus_name = 'user2'
			item2.item_pointer = pointer
			item2.text = '22222 22'
			item1.time = time
			item2.time = time
			item3 = AbstractInvoiceItem.new
			item3.yus_name = 'user1'
			item3.item_pointer = pointer
			item3.text = '33333 33'
			item3.time = time
			item4 = AbstractInvoiceItem.new
			item4.yus_name = 'user2'
			item4.item_pointer = pointer
			item4.text = '44444 44'
			item4.time = time
			company_donor1 = FlexMock.new
			company_donor2 = FlexMock.new
			company_donor1.should_receive(:company).and_return { company1 }
			company_donor2.should_receive(:company).and_return { company2 }
			companies = [company_donor1, company_donor2] * 2
			pointer.should_receive(:resolve).and_return { companies.shift }

			items = [item1, item2, item3, item4]
			comps = @plugin.group_by_company(items)
			comp1 = comps[company1]
			comp2 = comps[company2]
			assert_equal(3, comp1.size)
			item = comp1.shift
			assert_equal([item1, item3], comp1)
			assert_instance_of(AbstractInvoiceItem, item)
			assert_equal(1000, item.price)
			assert_equal(:activation, item.type)
			assert_equal([item2, item4], comp2)
		end
		def test_create_invoice
			ptr1 = FlexMock.new
			ptr2 = FlexMock.new
			ptr3 = FlexMock.new
			ptr1.should_receive(:resolve).and_return { } # disables the neighborhood_names check
			ptr2.should_receive(:resolve).and_return { }
			ptr3.should_receive(:resolve).and_return { }
			item1 = AbstractInvoiceItem.new
			item1.yus_name = 'user1'
			item1.item_pointer = ptr1
			item2 = AbstractInvoiceItem.new
			item2.yus_name = 'user1'
			item2.item_pointer = ptr2
			item3 = AbstractInvoiceItem.new
			item3.yus_name = 'user1'
			item3.item_pointer = ptr3
			items = [item1, item2, item3]
			pointer = Persistence::Pointer.new(:invoice)
			invoice = FlexMock.new
			stored_ptr = pointer.dup
			stored_ptr.append(1)
			invoice.should_receive(:pointer).and_return { stored_ptr }
			item_ptr = Persistence::Pointer.new([:invoice, 1], [:item])
			item_vals1 = {
				:data					=>	{},
				:duration			=>	1,
				:expiry_time	=>	nil,
				:item_pointer	=>	ptr1,
				:price				=>	nil,
				:quantity			=>	1,
				:text					=>	nil,
				:time					=>	nil,
				:type					=>	nil,
				:unit					=>	nil,
				:yus_name	=>	'user1',
				:vat_rate			=>	nil,
			}
			item_vals2 = item_vals1.dup
			item_vals2.store(:item_pointer, ptr2)
			item_vals3 = item_vals1.dup
			item_vals3.store(:item_pointer, ptr3)
			expected = [
				[pointer.creator, {:yus_name => 'user1', 
					:keep_if_unpaid => true, :ydim_id => 2134}, invoice],
				[item_ptr.dup.creator, item_vals1, nil],
				[item_ptr.dup.creator, item_vals2, nil],
				[item_ptr.dup.creator, item_vals3, nil],
			]
			@app.should_receive(:update, 4).and_return { |uptr, values| 
				exp_ptr, exp_vals, res = expected.shift
				assert_equal(exp_ptr, uptr)
				assert_equal(exp_vals, values)
				## flag the pointer as used (because Item.init appends 
				## an odba_id) the pointer must not be reused
				uptr.instance_variable_get('@directions').at(0).at(1).append('used')
				res
			}
			@plugin.create_invoice('user1', items, 2134)
			@app.flexmock_verify
		end
    def test_unique_name
      item = flexmock('item') do |item|
        item.should_receive(:text).and_return('12345 12')
      end
      assert_equal('12345_12', @plugin.unique_name(item))
    end
    def test_unique_name__else
      sequence = flexmock('sequence') do |seq|
        seq.should_receive(:is_a?).and_return(true)
        seq.should_receive(:iksnr).and_return('iksnr')
        seq.should_receive(:seqnr).and_return('seqnr')
      end
      item = flexmock('item') do |item|
        item.should_receive(:text).and_return('name')
        item.should_receive(:item_pointer).and_return(flexmock('ptr') do |ptr|
          ptr.should_receive(:resolve).and_return(sequence)
        end)
      end
      assert_equal('iksnr_seqnr', @plugin.unique_name(item))
    end
    def test_neighborhood_unique_names
      sequence = flexmock('sequence') do |seq|
        seq.should_receive(:pdf_patinfo).and_return('active')
        seq.should_receive(:iksnr).and_return('iksnr')
        seq.should_receive(:seqnr).and_return('seqnr')
      end
      flexstub(sequence) do |seq|
        seq.should_receive(:"registration.sequences")\
          .and_return({'key' => sequence})
      end
      item = flexmock('item') do |item|
        item.should_receive(:text).and_return('12345 12')
        item.should_receive(:item_pointer).and_return(flexmock('ptr') do |ptr|
          ptr.should_receive(:resolve).and_return(sequence)
        end)
      end
      expected = ["12345_12", "iksnr_seqnr"]
      assert_equal(expected, @plugin.neighborhood_unique_names(item))
    end
    def same?(o1, o2)
      if o1.instance_variables.sort == o2.instance_variables.sort
        vars = o1.instance_variables
        vars.delete('@time')
        vars.each do |v|
          if o1.instance_eval(v.to_s).to_s != o2.instance_eval(v.to_s).to_s
            return false
          end
        end
      else
        return false
      end
      return true
    end
    def test_html_items
      sequence = flexmock('sequence') do |seq|
        seq.should_receive(:public_package_count).and_return(1)
        seq.should_receive(:pdf_patinfo).and_return(false)
        seq.should_receive(:"patinfo.odba_instance").and_return('patinfo')
        seq.should_receive(:seqnr).and_return('seqnr')
        seq.should_receive(:pointer).and_return('pointer')
      end
      registration = flexmock('registration') do |reg|
        reg.should_receive(:active?).and_return(true)
        reg.should_receive(:each_sequence).and_yield(sequence)
        reg.should_receive(:iksnr).and_return('iksnr')
      end
      company = flexmock('company') do |comp|
        comp.should_receive(:invoice_htmlinfos).and_return(true)
        comp.should_receive(:invoice_date).and_return(123)
        comp.should_receive(:registrations).and_return([registration])
      end
      flexstub(@app) do |app|
        app.should_receive(:companies).and_return({'key' => company})
      end
      item = AbstractInvoiceItem.new
      item.price = PI_UPLOAD_PRICES[:annual_fee]
      item.text = 'iksnr seqnr'
      item.time = Time.now # @plugin.html_items(123)[0].time
      item.price = '120'
      item.type = :annual_fee
      item.unit = "Jahresgeb\374hr"
      item.vat_rate = VAT_RATE
      item.item_pointer = 'pointer'
#      assert_equal([item], @plugin.html_items(123))
      assert(same?(item, @plugin.html_items(123)[0]), 'item should match html_items(123)[0]') # if this fails, look at the result of comment line above
    end
	end
end

