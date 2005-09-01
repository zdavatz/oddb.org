#!/usr/bin/env ruby
# TestPatinfoInvoicer -- oddb -- 16.08.2005 -- jlang@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'stub/odba'
require 'plugin/patinfo_invoicer'
require 'model/invoice'

module ODDB
	class FlexMock < ::FlexMock
		undef :type
	end
	class TestPatinfoInvoicer < Test::Unit::TestCase
		def setup
			@app = FlexMock.new
			@plugin = PatinfoInvoicer.new(@app)
		end
		def test_assemble_pdf_invoice
			invoice = FlexMock.new
			item1 = AbstractInvoiceItem.new
			item1.user_pointer = 'user1'
			item1.text = '12345 03'
			item1.unit = 'Jahresgebühr'
			item1.quantity = 1
			item1.price = 120
			item2 = AbstractInvoiceItem.new
			item2.user_pointer = 'user1'
			item2.text = '12345 03'
			item2.unit = 'Jahresgebühr'
			item2.quantity = 1
			item2.price = 120
			item3 = AbstractInvoiceItem.new
			item3.user_pointer = 'user1'
			item3.text = '12345 03'
			item3.unit = 'Jahresgebühr'
			item3.quantity = 1
			item3.price = 120
			items = [item1, item2, item3]
			day = Date.today - 1
			invoice.mock_handle(:invoice_number=, 1) { |num|
				expected = day.strftime('Patinfo-Upload-%d.%m.%Y')
				assert_equal(expected, num)
			}
			invoice.mock_handle(:debitor_address=, 1) { |arry|
				lines = [
					'Test AG',
					'z.H. A. Bachmann',
					'abachman@test.com',
					'Bümplitzstrasse 2',
					'3006 Bern',
				]
				assert_equal(lines, arry)
			}
			invoice.mock_handle(:items=, 1) { |list|
				expected = [
					[day, '12345 03 (Ponstan)', 'Jahresgebühr', 1, 120],
					[day, '12345 03 (Zithromax)', 'Jahresgebühr', 1, 120],
					[day, '12345 03 (Celebrex)', 'Jahresgebühr', 1, 120],
				]
			}
			invoice.mock_handle(:to_pdf) { 'pdf-document' }
			company = FlexMock.new
			address = FlexMock.new
			company.mock_handle(:address) { address }
			company.mock_handle(:name) { 'Test AG' }
			address.mock_handle(:lines) { 
				['Bümplitzstrasse 2', '3006 Bern']
			}
			email = 'abachman@test.com'
			company.mock_handle(:contact) { 'A. Bachmann' }
			@plugin.assemble_pdf_invoice(invoice, day, company, items, email)
			invoice.mock_verify
		end
		def test_filter_paid
			day = Date.today - 1
			## Item that has been paid more than a year ago
			## (inv1) - should be in new invoice
			item1 = AbstractInvoiceItem.new
			item1.item_pointer = 'model 1'
			item1.type = :annual_fee
			item1.time = Time.local(day.year, day.month, 
				day.day, 10, 32)
			## Item that has never before been uploaded
			## should be in new invoice
			item2 = AbstractInvoiceItem.new
			item2.item_pointer = 'model 2'
			item2.type = :annual_fee
			item2.time = Time.local(day.year, day.month, 
				day.day, 10, 32)
			## Item that is already once in new invoice
			## (item1) - should not be in new invoice
			item3 = AbstractInvoiceItem.new
			item3.item_pointer = 'model 1'
			item3.type = :annual_fee
			item3.time = Time.local(day.year, day.month, 
				day.day, 16, 23)
			## Item that has been paid less than a year ago
			## (inv2) - should not be in new invoice
			item4 = AbstractInvoiceItem.new
			item4.item_pointer = 'model 3'
			item4.type = :annual_fee
			item4.time = Time.local(day.year, day.month, 
				day.day, 16, 23)
			items = [item1, item2, item3, item4]

			inv1 = FlexMock.new
			inv1.mock_handle(:items) {
				itm1 = FlexMock.new
				itm1.mock_handle(:expired?) { true }
				itm1.mock_handle(:type) { :annual_fee }
				itm1.mock_handle(:item_pointer) { 'model 1' }
				itm2 = FlexMock.new
				itm2.mock_handle(:expired?) { false }
				itm2.mock_handle(:type) { :processing }
				itm2.mock_handle(:item_pointer) { 'model 1' }
				{1 => itm1, 2 => itm2}
			}
			inv2 = FlexMock.new
			inv2.mock_handle(:items) {
				itm1 = FlexMock.new
				itm1.mock_handle(:expired?) { false }
				itm1.mock_handle(:type) { :annual_fee }
				itm1.mock_handle(:item_pointer) { 'model 3' }
				{1 => itm1}
			}
			inv3 = FlexMock.new
			inv3.mock_handle(:items) {
				itm1 = FlexMock.new
				itm1.mock_handle(:expired?) { false }
				itm1.mock_handle(:type) { :annual_fee }
				itm1.mock_handle(:item_pointer) { 'model 4' }
				{1 => itm1}
			}
			@app.mock_handle(:invoices) { 
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
			today = Date.today
			item1 = AbstractInvoiceItem.new
			item1.time = Time.local(today.year, today.month,
				today.day) - (24*60*60)
			item2 = AbstractInvoiceItem.new
			item2.time = Time.local(today.year, today.month,
				today.day, 23, 59, 59) - (2*24*60*60)
			item3 = AbstractInvoiceItem.new
			item3.time = Time.local(today.year, today.month,
				today.day, 23, 59, 59) - (24*60*60)
			item4 = AbstractInvoiceItem.new
			item4.time = Time.local(today.year, today.month,
				today.day)
			items = {
				1	=>	item1,
				2	=>	item2,
				3	=>	item3,
				4	=>	item4,
			}
			slate = FlexMock.new
			slate.mock_handle(:items) {
				items
			}
			@app.mock_handle(:slate) { |name| 
				assert_equal(:patinfo, name)
				slate
			}
			assert_equal([item1, item3], @plugin.recent_items(today - 1))
		end
		def test_group_by_company
			old_invoice = FlexMock.new
			@app.mock_handle(:invoices) { { 1 => old_invoice } }
			old_item = FlexMock.new
			old_invoice.mock_handle(:items) { { 1 => old_item } }
			old_item.mock_handle(:type) { :annual_fee }
			item_pointer = FlexMock.new
			old_item.mock_handle(:item_pointer) { item_pointer }
			sequence = FlexMock.new
			item_pointer.mock_handle(:resolve) { sequence }
			sequence.mock_handle(:company) { 'company2' }
			pointer = FlexMock.new
			item1 = AbstractInvoiceItem.new
			item1.user_pointer = 'user1'
			item1.item_pointer = pointer
			item2 = AbstractInvoiceItem.new
			item2.user_pointer = 'user2'
			item2.item_pointer = pointer
			item3 = AbstractInvoiceItem.new
			item3.user_pointer = 'user1'
			item3.item_pointer = pointer
			item4 = AbstractInvoiceItem.new
			item4.user_pointer = 'user2'
			item4.item_pointer = pointer
			company_donor1 = FlexMock.new
			company_donor2 = FlexMock.new
			company_donor1.mock_handle(:company) { 'company1' }
			company_donor2.mock_handle(:company) { 'company2' }
			companies = [company_donor1, company_donor2] * 2
			pointer.mock_handle(:resolve) { companies.shift }

			items = [item1, item2, item3, item4]
			comps = @plugin.group_by_company(items)
			comp1 = comps['company1']
			comp2 = comps['company2']
			assert_equal(3, comp1.size)
			item = comp1.shift
			assert_equal([item1, item3], comp1)
			assert_instance_of(AbstractInvoiceItem, item)
			assert_equal(1000, item.price)
			assert_equal(:activation, item.type)
			assert_equal([item2, item4], comp2)
		end
		def test_create_invoice
			item1 = AbstractInvoiceItem.new
			item1.user_pointer = 'user1'
			item1.item_pointer = 'item1'
			item2 = AbstractInvoiceItem.new
			item2.user_pointer = 'user1'
			item2.item_pointer = 'item2'
			item3 = AbstractInvoiceItem.new
			item3.user_pointer = 'user1'
			item3.item_pointer = 'item3'
			items = [item1, item2, item3]
			pointer = Persistence::Pointer.new(:invoice)
			invoice = FlexMock.new
			stored_ptr = pointer.dup
			stored_ptr.append(1)
			invoice.mock_handle(:pointer) { stored_ptr }
			item_ptr = Persistence::Pointer.new([:invoice, 1], [:item])
			item_vals1 = {
				:data					=>	{},
				:duration			=>	1,
				:expiry_time	=>	nil,
				:item_pointer	=>	'item1',
				:price				=>	nil,
				:quantity			=>	1,
				:text					=>	nil,
				:time					=>	nil,
				:type					=>	nil,
				:unit					=>	nil,
				:user_pointer	=>	'user1',
				:vat_rate			=>	nil,
			}
			item_vals2 = item_vals1.dup
			item_vals2.store(:item_pointer, 'item2')
			item_vals3 = item_vals1.dup
			item_vals3.store(:item_pointer, 'item3')
			expected = [
				[pointer.creator, {:user_pointer => 'user1', 
					:keep_if_unpaid => true}, invoice],
				[item_ptr.dup.creator, item_vals1, nil],
				[item_ptr.dup.creator, item_vals2, nil],
				[item_ptr.dup.creator, item_vals3, nil],
			]
			@app.mock_handle(:update, 4) { |ptr, values| 
				exp_ptr, exp_vals, res = expected.shift
				assert_equal(exp_ptr, ptr)
				assert_equal(exp_vals, values)
				## flag the pointer as used (because Item.init appends 
				## an odba_id) the pointer must not be reused
				ptr.instance_variable_get('@directions').at(0).at(1).append('used')
				res
			}
			user = FlexMock.new
			user.mock_handle(:pointer) { 'user1' }
			@plugin.create_invoice(user, items)
			@app.mock_verify
		end
	end
end
