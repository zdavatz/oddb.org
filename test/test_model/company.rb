#!/usr/bin/env ruby
# encoding: utf-8
# TestCompany -- oddb -- 28.03.2011 -- mhatakeyama@ywesee.com
# TestCompany -- oddb -- 28.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/company'

module ODDB
	class Company
		attr_accessor :registrations
		public :adjust_types
	end
end

class TestCompany <Minitest::Test
  include FlexMock::TestCase
	class StubRegistration
	end
	class StubApp
		attr_reader :companies
		def initialize
			@companies ||= {}
		end
		def create_company
			company = ODDB::Company.new
			@companies.store(company.oid, company)
		end
	end
	class StubSession
		attr_accessor :app
		def app
			@app ||= StubApp.new
		end
	end

	def setup
		@session = StubSession.new
		@company = @session.app.create_company
	end
  def test_active_package_count
    reg1 = flexmock :active_package_count => 2
    reg2 = flexmock :active_package_count => 1
    @company.registrations.push reg1, reg2
    assert_equal 3, @company.active_package_count
  end
	def test_add_registration
		@company.registrations = []
		reg = StubRegistration.new
		@company.add_registration(reg)
		assert_equal([reg], @company.registrations)
	end
  def test_atc_classes
    reg1 = flexmock :atc_classes => ['atc1', 'atc2', nil]
    reg2 = flexmock :atc_classes => ['atc1', 'atc3', 'atc4' ]
    @company.registrations.push reg1, reg2
    assert_equal ['atc1', 'atc2', 'atc3', 'atc4'], @company.atc_classes
  end
  def test_disable_invoice_fachinfo
    assert_equal nil, @company.disable_invoice_fachinfo
    @company.disable_invoice_fachinfo = true
    assert_equal true, @company.disable_invoice_fachinfo
    @company.disable_invoice_fachinfo = false
    assert_equal false, @company.disable_invoice_fachinfo
  end
  def test_disable_invoice_patinfo
    assert_equal nil, @company.disable_invoice_patinfo
    @company.disable_invoice_patinfo = true
    assert_equal true, @company.disable_invoice_patinfo
    @company.disable_invoice_patinfo = false
    assert_equal false, @company.disable_invoice_patinfo
  end
  def test_inactive_packages
    pac1 = flexmock :market_date => nil
    pac2 = flexmock :market_date => Date.today + 1
    pac3 = flexmock :market_date => Date.today
    pac4 = flexmock :market_date => Date.today + 2
    pac5 = flexmock :market_date => Date.today - 1
    reg1 = flexmock :packages => [pac1, pac2, pac3]
    reg2 = flexmock :packages => [pac4, pac5]
    @company.registrations.push reg1, reg2
    assert_equal [pac2, pac4], @company.inactive_packages
  end
  def test_inactive_registrations
    reg1 = flexmock :public_package_count => 1
    reg2 = flexmock :public_package_count => 0
    @company.registrations.push reg1, reg2
    assert_equal [reg2], @company.inactive_registrations
  end
  def test_invoiceable
    assert_equal false, @company.invoiceable?
    @company.name = 'Name'
    @company.contact = 'Contact'
    @company.invoice_email = 'Invoice Email'
    addr = @company.address(0)
    addr.address = 'Street, Number'
    addr.location = '1234 City'
    addr.fon = 'Phone Number'
    assert_equal true, @company.invoiceable?
    [:address, :location, :fon].each do |key|
      old = addr.send(key)
      addr.send("#{key}=", nil)
      assert_equal false, @company.invoiceable?
      addr.send("#{key}=", old)
    end
    [:name, :contact, :invoice_email].each do |key|
      old = @company.send(key)
      @company.send("#{key}=", nil)
      assert_equal false, @company.invoiceable?
      @company.send("#{key}=", old)
    end
    assert_equal true, @company.invoiceable?
  end
  def test_invoice_date_patinfo
    date = Date.today
    @company.invoice_date_patinfo = date
    assert_equal(date, @company.invoice_date_patinfo)
    @company.invoice_date_patinfo = date >> 1
    assert_equal(date >> 1, @company.invoice_date_patinfo)

    today_bak = @company.today
    # Normal year
    date = Date.new(2010,1,2)
    @company.instance_eval('@@today = Date.new(2011,4,1)')
    @company.invoice_date_patinfo = date
    expected = Date.new(2012,1,2)
    assert_equal(expected, @company.invoice_date_patinfo)

    # Check leap year
    date = Date.new(2008,2,29)
    @company.instance_eval('@@today = Date.new(2011,4,1)')
    @company.invoice_date_patinfo = date
    expected = Date.new(2012,2,28)
    assert_equal(expected, @company.invoice_date_patinfo)

    @company.instance_eval('@@today = today_bak')
  end
  def test_invoice_date_fachinfo
    date = Date.today
    @company.invoice_date_fachinfo = date
    assert_equal(date, @company.invoice_date_fachinfo)
    @company.invoice_date_fachinfo = date >> 1
    assert_equal(date >> 1, @company.invoice_date_fachinfo)

    today_bak = @company.today
    # Normal year
    date = Date.new(2010,1,2)
    @company.instance_eval('@@today = Date.new(2011,4,1)')
    @company.invoice_date_fachinfo = date
    expected = Date.new(2012,1,2)
    assert_equal(expected, @company.invoice_date_fachinfo)

    # Check leap year
    date = Date.new(2008,2,29)
    @company.instance_eval('@@today = Date.new(2011,4,1)')
    @company.invoice_date_fachinfo = date
    expected = Date.new(2012,2,28)
    assert_equal(expected, @company.invoice_date_fachinfo)

    @company.instance_eval('@@today = today_bak')
  end
  def test_invoice_date_index
    date = Date.today
    @company.invoice_date_index = date
    assert_equal(date, @company.invoice_date_index)
    @company.invoice_date_index = date >> 1
    assert_equal(date >> 1, @company.invoice_date_index)

    today_bak = @company.today
    # Normal year
    date = Date.new(2010,1,2)
    @company.instance_eval('@@today = Date.new(2011,4,1)')
    @company.invoice_date_index = date
    expected = Date.new(2012,1,2)
    assert_equal(expected, @company.invoice_date_index)

    # Check leap year
    date = Date.new(2008,2,29)
    @company.instance_eval('@@today = Date.new(2011,4,1)')
    @company.invoice_date_index = date
    expected = Date.new(2012,2,28)
    assert_equal(expected, @company.invoice_date_index)

    @company.instance_eval('@@today = today_bak')
  end
  def test_invoice_date_lookandfeel
    date = Date.today
    @company.invoice_date_lookandfeel = date
    assert_equal(date, @company.invoice_date_lookandfeel)
    @company.invoice_date_lookandfeel = date >> 1
    assert_equal(date >> 1, @company.invoice_date_lookandfeel)

    today_bak = @company.today
    # Normal year
    date = Date.new(2010,1,2)
    @company.instance_eval('@@today = Date.new(2011,4,1)')
    @company.invoice_date_lookandfeel = date
    expected = Date.new(2012,1,2)
    assert_equal(expected, @company.invoice_date_lookandfeel)

    # Check leap year
    date = Date.new(2008,2,29)
    @company.instance_eval('@@today = Date.new(2011,4,1)')
    @company.invoice_date_lookandfeel = date
    expected = Date.new(2012,2,28)
    assert_equal(expected, @company.invoice_date_lookandfeel)

    @company.instance_eval('@@today = today_bak')
  end
  def test_listed
    assert_equal false, @company.listed?
    @company.cl_status = true
    assert_equal true, @company.listed?
    @company.cl_status = false
    assert_equal false, @company.listed?
  end
  def test_merge
    reg1 = flexmock :odba_isolated_store => :ignore
    reg2 = flexmock :odba_isolated_store => :ignore
    other = ODDB::Company.new 
    other.registrations.push reg1, reg2
    reg1.should_receive(:company=).with(@company).times(1).and_return do
      other.registrations.delete reg1
      @company.registrations.push reg1
      assert true
    end
    reg2.should_receive(:company=).with(@company).times(1).and_return do
      other.registrations.delete reg2
      @company.registrations.push reg2
      assert true
    end
    @company.merge other
    assert_equal [reg1, reg2], @company.registrations
  end
  def test_packages
    reg1 = flexmock :packages => ['package1', 'package2']
    reg2 = flexmock :packages => ['package3', 'package4', 'package5']
    @company.registrations.push reg1, reg2
    assert_equal ['package1', 'package2', 'package3', 'package4', 'package5'],
                 @company.packages
  end
  def test_pointer_descr
    @company.name = 'Company-Name'
    assert_equal 'Company-Name', @company.pointer_descr
  end
  def test_prices
    assert_nil @company.price_fachinfo
    assert_nil @company.price(:fachinfo)
    @company.price_fachinfo = 100
    assert_equal 100, @company.price_fachinfo
    assert_equal 100, @company.price(:fachinfo)
    assert_nil @company.price_index
    assert_nil @company.price(:index)
    @company.price_index = 100
    assert_equal 100, @company.price_index
    assert_equal 100, @company.price(:index)
    assert_nil @company.price_index_package
    assert_nil @company.price(:index_package)
    @company.price_index_package = 100
    assert_equal 100, @company.price_index_package
    assert_equal 100, @company.price(:index_package)
    assert_nil @company.price_lookandfeel
    assert_nil @company.price(:lookandfeel)
    @company.price_lookandfeel = 100
    assert_equal 100, @company.price_lookandfeel
    assert_equal 100, @company.price(:lookandfeel)
    assert_nil @company.price_lookandfeel_member
    assert_nil @company.price(:lookandfeel_member)
    @company.price_lookandfeel_member = 100
    assert_equal 100, @company.price_lookandfeel_member
    assert_equal 100, @company.price(:lookandfeel_member)
    assert_nil @company.price_patinfo
    assert_nil @company.price(:patinfo)
    @company.price_patinfo = 100
    assert_equal 100, @company.price_patinfo
    assert_equal 100, @company.price(:patinfo)
  end
	def test_remove_registration
		reg = StubRegistration.new
		@company.registrations = [reg]
		@company.remove_registration(reg)
		assert_equal([], @company.registrations)
	end
  def test_search_terms
    @company.name = 'Company-Name'
    @company.ean13 = '7681123456789'
    addr = @company.address(0)
    addr.address = 'Street, Number'
    addr.location = '1234 City'
    expected = [
      'Company', 'Name', 'Company', 'CompanyName', 'Company Name', 
       "7681123456789", "Street Number", "1234 City", "City", "1234"
    ]
    assert_equal expected, @company.search_terms
  end
	def test_update_values
		values = {
			:name						=>	'ywesee.com',
			:cl_status			=>	true,
			:url						=>	'www.ywesee.com',
			:business_area	=>	'Intellectual Capital',
			:contact				=>	'hwyss at ywesee.com',
		}
		reg = StubRegistration.new
		@company.add_registration(reg)
		assert_equal(nil, @company.name)
		@company.update_values(values)
		assert_equal('ywesee.com', @company.name)
		assert_equal(true, @company.cl_status)
		assert_equal('www.ywesee.com', @company.url)
		assert_equal('Intellectual Capital', @company.business_area)
		assert_equal('hwyss at ywesee.com', @company.contact)
		assert_equal([reg], @company.registrations)
	end		
	def test_adjust_types
		values = {
			:name						=>	'ywesee.com',
			:cl_status			=>	true,
			:url						=>	'www.ywesee.com',
			:business_area	=>	'Intellectual Capital',
			:contact				=>	'hwyss at ywesee.com',
			:address				=>	'Winterthurerstrasse',
			:plz						=>	'8000',
      :powerlink      =>  '',
			:location				=>	'Zuerich',
      :generic_type   =>  'original',
      :complementary_type => 'homeopathy',
      :price_lookandfeel => '12',
		}
		expected = {
			:name						=>	'ywesee.com',
			:cl_status			=>	true,
			:url						=>	'www.ywesee.com',
			:business_area	=>	'Intellectual Capital',
			:contact				=>	'hwyss at ywesee.com',
			:address				=>	'Winterthurerstrasse',
			:plz						=>	'8000',
      :powerlink      =>  nil,
			:location				=>	'Zuerich',
      :generic_type   =>  :original,
      :complementary_type => :homeopathy,
      :price_lookandfeel => 1200,
		}
		assert_equal(expected, @company.adjust_types(values))
	end
  def test_init
    @company.pointer = ODDB::Persistence::Pointer.new [:company]
    @company.init nil
    pointer = ODDB::Persistence::Pointer.new [:company, @company.oid]
    assert_equal pointer, @company.pointer
  end
  def test__yearly_repetition
    # This is a testcase for a private method
    today_bak = @company.today
    @company.instance_eval('@@today = Date.new(2011,2,3)')
    date = Date.new(2008,2,29)
    expected = Date.new(2011,2,28)
    assert_equal(expected, @company.instance_eval('_yearly_repetition(date)'))
    @company.instance_eval('@@today = today_bak')
  end
end
