#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Companies::TestCompany -- oddb.org -- 08.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/companies/company'

module ODDB
  module View
    class Session
      DEFAULT_FLAVOR = 'gcc'
    end
  end
end

class TestUnknownCompanyInnerComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:attributes).and_return({})
    end
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
    end
    @model = flexmock('model') do |m|
      m.should_receive(:address)
    end
    @composite = ODDB::View::Companies::UnknownCompanyInnerComposite.new(@model, @session)
  end
  def test_address
    assert_kind_of(ODDB::View::Address, @composite.address(@model))
  end
end

class TestUserCompanyForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:attributes).and_return({})
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:_event_url)
      l.should_receive(:base_url)
    end
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
      s.should_receive(:error)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:info?)
    end
    @model = flexmock('model') do |m|
      m.should_receive(:address)
      m.should_receive(:pointer)
      m.should_receive(:ean13)
      m.should_receive(:oid).and_return('123')
    end
    @form = ODDB::View::Companies::UserCompanyForm.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @form.init)
  end
  def test_address
    assert_kind_of(HtmlGrid::InputText, @form.address(@model, @session))
  end
  def test_address_delegate
    assert_kind_of(HtmlGrid::InputText, @form.address_delegate(@model, :address))
  end
  def test_address_delegate__input_array
    input_text = flexmock('input_text') do |i|
      i.should_receive(:value).and_return([])
      i.should_receive(:value=)
    end
    flexmock(HtmlGrid::InputText, :new => input_text)
    assert_equal(input_text, @form.address_delegate(@model, :address))
  end
  def test_set_pass
    assert_kind_of(HtmlGrid::Button, @form.set_pass(@model, @session))
  end
end

class TestAjaxCompanyForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:attributes).and_return({})
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:_event_url)
      l.should_receive(:base_url)
    end
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
      s.should_receive(:error)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:info?)
    end
    @model = flexmock('model') do |m|
      m.should_receive(:address)
      m.should_receive(:pointer)
      m.should_receive(:ean13)
      m.should_receive(:oid).and_return('123')
    end
    @form = ODDB::View::Companies::AjaxCompanyForm.new(@model, @session)
  end
  def test_business_area
    assert_kind_of(HtmlGrid::Select, @form.business_area(@model, @session))
  end
end

class TestUnknownCompanyComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:attributes).and_return({})
      l.should_receive(:lookup).and_return('lookup')
    end
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
    end
    @model = flexmock('model') do |m|
      m.should_receive(:ean13).and_return('ean13')
      m.should_receive(:address)
      m.should_receive(:logo_filename)
    end
    @composite = ODDB::View::Companies::UnknownCompanyComposite.new(@model, @session)
  end
  def test_company_name
    assert_kind_of(HtmlGrid::Value, @composite.company_name(@model, @session))
  end
  def test_ean13
    assert_equal('&nbsp;-&nbsp;ean13', @composite.ean13(@model, @session))
  end
end

class TestUserCompanyComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:attributes).and_return({})
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:_event_url)
      l.should_receive(:base_url)
    end
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
      s.should_receive(:error)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:info?)
      s.should_receive(:event)
    end
    @model = flexmock('model') do |m|
      m.should_receive(:ean13).and_return('ean13')
      m.should_receive(:address)
      m.should_receive(:logo_filename)
      m.should_receive(:pointer)
      m.should_receive(:inactive_registrations)
      m.should_receive(:inactive_packages)
    end
    @composite = ODDB::View::Companies::UserCompanyComposite.new(@model, @session)
  end
  def test_inactive_packages
    assert_kind_of(ODDB::View::Companies::InactivePackages, @composite.inactive_packages(@model, @session))
  end
end

class TestRootPharmaCompanyComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:attributes).and_return({})
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:_event_url)
      l.should_receive(:base_url)
    end
    entity = flexmock('entity') do |e|
      e.should_receive(:get_preference)
      e.should_receive(:name)
      e.should_receive(:affiliations).and_return([])
    end
    user = flexmock('user') do |u|
      u.should_receive(:entities).and_return([entity])
    end
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
      s.should_receive(:error)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:info?)
      s.should_receive(:event)
      s.should_receive(:user).and_return(user)
    end
    @model = flexmock('model') do |m|
      m.should_receive(:ean13).and_return('ean13')
      m.should_receive(:address)
      m.should_receive(:logo_filename)
      m.should_receive(:pointer)
      m.should_receive(:inactive_registrations)
      m.should_receive(:inactive_packages)
      m.should_receive(:business_area).by_default
    end
    @composite = ODDB::View::Companies::RootPharmaCompanyComposite.new(@model, @session)
  end
  def test_select_company_form
    flexmock(@model, :business_area => 'bussiness_area')
    assert_equal(ODDB::View::Companies::AjaxOtherCompanyForm, ODDB::View::Companies::RootPharmaCompanyComposite.select_company_form(@model))
  end
  def test_select_company_form__ba_pharma
    flexmock(@model, :business_area => 'ba_pharma')
    assert_equal(ODDB::View::Companies::AjaxPharmaCompanyForm, ODDB::View::Companies::RootPharmaCompanyComposite.select_company_form(@model))
  end
  def test_select_company_form__ba_insurance
    flexmock(@model, :business_area => 'ba_insurance')
    assert_equal(ODDB::View::Companies::AjaxInsuranceCompanyForm, ODDB::View::Companies::RootPharmaCompanyComposite.select_company_form(@model))
  end
  def test_select_company_form__ba_info
    flexmock(@model, :business_area => 'ba_info')
    assert_equal(ODDB::View::Companies::AjaxInfoCompanyForm, ODDB::View::Companies::RootPharmaCompanyComposite.select_company_form(@model))
  end
end

module ODDB
  module View
    class Copyright < HtmlGrid::Composite
      ODDB_VERSION = 'oddb_version'
    end
  end
end
class TestRootCompany <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:enabled?)
      l.should_receive(:attributes).and_return({})
      l.should_receive(:resource)
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:zones).and_return([])
      l.should_receive(:disabled?)
      l.should_receive(:direct_event)
      l.should_receive(:_event_url)
      l.should_receive(:base_url)
      l.should_receive(:zone_navigation).and_return('')
      l.should_receive(:navigation).and_return([])
    end
    entity = flexmock('entity') do |e|
      e.should_receive(:get_preference)
      e.should_receive(:name)
      e.should_receive(:affiliations).and_return([])
    end
    user = flexmock('user') do |u|
      u.should_receive(:valid?)
      u.should_receive(:entities).and_return([entity])
    end
    state = flexmock('state') do |s|
      s.should_receive(:direct_event)
      s.should_receive(:previous)
      s.should_receive(:snapback_model)
    end
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(@lookandfeel)
      s.should_receive(:user).and_return(user)
      s.should_receive(:sponsor)
      s.should_receive(:state).and_return(state)
      s.should_receive(:error)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:info?)
      s.should_receive(:event)
      s.should_receive(:flavor)
      s.should_receive(:zone)
    end
    @model = flexmock('model') do |m|
      m.should_receive(:business_area).by_default
      m.should_receive(:address)
      m.should_receive(:logo_filename)
    end
    @company = ODDB::View::Companies::RootCompany.new(@model, @session)
  end
  def test_select_company_content
    flexmock(@model, :business_area => 'ba_pharma')
    assert_equal(ODDB::View::Companies::RootPharmaCompanyComposite, ODDB::View::Companies::RootCompany.select_company_content(@model))
  end
  def test_content
    assert_kind_of(ODDB::View::Companies::RootOtherCompanyComposite, @company.content(@model, @session))
  end
  def test_other_html_headers
    flexmock(@lookandfeel, :resource_global => 'resource_global')
    context = flexmock('context') do |c|
      c.should_receive(:script).once.and_return('script')
      c.should_receive(:script).and_return('')
      c.should_receive(:style).and_return('')
    end
    assert_equal('script', @company.other_html_headers(context))
  end
end
