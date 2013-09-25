#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestRegistration -- oddb.org -- 05.08.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/admin/registration'
require 'htmlgrid/span'
require 'util/pointerarray'

module ODDB
  module View
    module Admin
module TestSetup
  def htmlgrid_setup
    @lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:attributes).and_return({})
      l.should_receive(:event_url)
      l.should_receive(:_event_url)
      l.should_receive(:base_url)
    end
    @session = flexmock('session') do |s|
      s.should_receive(:event)
      s.should_receive(:lookandfeel).and_return(@lookandfeel)
      s.should_receive(:allowed?)
      s.should_receive(:info?)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:state)
      s.should_receive(:language).and_return('language')
      s.should_receive(:error)
    end
    galenic_form = flexmock('galenic_form') do |g|
      g.should_receive(:language).and_return('galenic_form_language')
    end
    substance = flexmock('substance') do |s|
      s.should_receive(:language).and_return('substance_language')
    end
    active_agent = flexmock('active_agent') do |a|
      a.should_receive(:substance).and_return(substance)
      a.should_receive(:dose).and_return('dose')
    end
    composition = flexmock('composition') do |c|
      c.should_receive(:galenic_form).and_return(galenic_form)
      c.should_receive(:active_agents).and_return([active_agent])
    end
    atc_class = flexmock('atc_class') do |a|
      a.should_receive(:code).and_return('code')
    end
    @model = flexmock('model') do |m|
      m.should_receive(:pointer)
      m.should_receive(:seqnr)
      m.should_receive(:compositions).and_return([composition])
      m.should_receive(:atc_class).and_return(atc_class)
      m.should_receive(:has_patinfo?)
    end
  end
end

class TestRegistrationSequences <Minitest::Test
  include FlexMock::TestCase
  include ODDB::View::Admin::TestSetup
  def setup
    htmlgrid_setup
    @pointer = flexmock('pointer', :to_csv => 'pointer')
    flexmock(@model, :pointer => @pointer)
    @list = ODDB::View::Admin::RegistrationSequences.new([@model], @session)
  end
  def test_atc_class
    assert_equal('code', @list.atc_class(@model, @session))
  end
  def test_galenic_form
    expected = "galenic_form_language (substance_language dose)"
    assert_equal(expected, @list.galenic_form(@model, @session))
  end
  def test_seqnr
    flexmock(@pointer, :to_csv => "registration,12345,sequence,123,package,12")
    assert_kind_of(HtmlGrid::Link, @list.seqnr(@model, @session))
  end
  def test_seqnr__edit
    flexmock(@session, :allowed? => true)
    method = flexmock('method', :arity => nil)
    flexmock(@model, :method => method)
    assert_kind_of(ODDB::View::PointerLink, @list.seqnr(@model, @session))
  end
end
class TestRootRegistrationSequences <Minitest::Test
  include FlexMock::TestCase
  include ODDB::View::Admin::TestSetup
  def setup
    htmlgrid_setup
    pointer = flexmock('pointer', :to_csv => "pointer")
    flexmock(@model, :pointer => pointer)
    @list = ODDB::View::Admin::RootRegistrationSequences.new([@model], @session)
  end
  def test_compose_empty_list
    assert_equal([0,1], @list.compose_empty_list([0,0]))
  end
end

class TestFachinfoLanguageSelect <Minitest::Test
  include FlexMock::TestCase
  include ODDB::View::Admin::TestSetup
  def setup
    htmlgrid_setup
    @select = ODDB::View::Admin::FachinfoLanguageSelect.new('name', @model, @session)
  end
  def test_selection
    context = flexmock('context') do |c|
      c.should_receive(:option).and_yield
    end
    expected = ['lookup', 'lookup']
    assert_equal(expected, @select.selection(context))

  end
end

class TestRegistrationInnerComposite <Minitest::Test
  include FlexMock::TestCase
  include ODDB::View::Admin::TestSetup
  def setup
    htmlgrid_setup
    flexmock(@model) do |m|
      m.should_receive(:generic_type).and_return('generic_type')
      m.should_receive(:fachinfo_active?)
      m.should_receive(:has_fachinfo?)
    end
    @composite = ODDB::View::Admin::RegistrationInnerComposite.new(@model, @session)
  end
  def test_generic_type
    assert_kind_of(HtmlGrid::Label, @composite.generic_type(@model, @session))
  end
end

class TestRegistrationForm <Minitest::Test
  include FlexMock::TestCase
  include ODDB::View::Admin::TestSetup
  def setup
    htmlgrid_setup
    @user = flexmock('user') do |u|
      u.should_receive(:allowed?)
    end
    flexmock(@session) do |s|
      s.should_receive(:user).and_return(@user)
    end
    patent = flexmock('patent') do |p|
      p.should_receive(:expiry_date)
    end
    sequence = flexmock('sequence') do |s|
      s.should_receive(:violates_patent?)
    end
    @model = flexmock('model') do |m|
      m.should_receive(:complementary_type).and_return('complementary_type')
      m.should_receive(:has_fachinfo?)
      m.should_receive(:fachinfo).and_return('fachinfo')
      m.should_receive(:indication).and_return('indication')
      m.should_receive(:patent).and_return(patent)
      m.should_receive(:pointer)
      m.should_receive(:ignore_patent?)
      m.should_receive(:sequences).and_return({'seqnr' => sequence})
    end
    @form = ODDB::View::Admin::RegistrationForm.new(@model, @session)
  end
  def test_assign_fachinfo
    assert_kind_of(HtmlGrid::Link, @form.assign_fachinfo(@model, @session))
  end
  def test_reorganize_components
    flexmock(@model, :is_a? => true)
    assert_equal('list', @form.reorganize_components)
  end
  def test_reorganize_components__else
    assert_equal('standard', @form.reorganize_components)
  end
  def test_company_name
    assert_kind_of(HtmlGrid::InputText, @form.company_name(@model, @session))
  end
  def test_company_name__company_user
    flexmock(@user) do |u|
      u.should_receive(:allowed?).and_return(true)
    end
    assert_kind_of(HtmlGrid::Value, @form.company_name(@model, @session))
  end
  def test__fachinfo
    flexmock(@model) do |m|
      m.should_receive(:has_fachinfo?).and_return(true)
      m.should_receive(:iksnr).and_return('iksnr')
    end
    assert_kind_of(HtmlGrid::Link, @form._fachinfo(@model))
  end
  def test_iksnr
    flexmock(@model, :is_a? => true)
    assert_kind_of(HtmlGrid::InputText, @form.iksnr(@model, @session))
  end
  def test_iksnr__else
    assert_kind_of(HtmlGrid::Value, @form.iksnr(@model, @session))
  end
  def test_patented_until
    patent = flexmock('patent') do |p|
      p.should_receive(:expiry_date).and_return(Time.local(2011,2,3))
      p.should_receive(:pointer)
    end
    flexmock(@lookandfeel, :format_date => 'format_date')
    flexmock(@model, :patent => patent)
    assert_kind_of(HtmlGrid::Link, @form.patented_until(@model, @session))
  end
  def test_patented_until__else
    assert_kind_of(HtmlGrid::Link, @form.patented_until(@model, @session))
  end
  def test_violates_patent
    flexmock(@model, :ignore_patent? => true)
    assert_equal('lookup', @form.violates_patent(@model, @session))
  end
end

class TestResellerRegistrationForm <Minitest::Test
  include FlexMock::TestCase
  include ODDB::View::Admin::TestSetup
  def setup
    htmlgrid_setup
    pointer = flexmock('pointer', :to_csv => "pointer")
    @company = flexmock('company') do |c|
      c.should_receive(:invoiceable?)
      c.should_receive(:pointer).and_return(pointer)
    end
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(@company)
      m.should_receive(:fachinfo_active?)
      m.should_receive(:has_fachinfo?)
    end
    @form = ODDB::View::Admin::ResellerRegistrationForm.new(@model, @session)
  end
  def test_reorganize_components
    flexmock(@company, :invoiceable? => true)
    expected = {
      [0, 0, 4, 3]  => "list",
      [0, 3]        => "list bold",
      [2, 3, 2]     => "list",
      [0, 4, 2, 3]  => "list bg",
      [1, 3]        => "list bg",
    }
    assert_equal(expected, @form.reorganize_components)
  end
end

class TestRegistrationComposite <Minitest::Test
  include FlexMock::TestCase
  include ODDB::View::Admin::TestSetup
  def setup
    htmlgrid_setup
    galenic_form = flexmock('galenic_form') do |g|
      g.should_receive(:language).and_return('galenic_form_language')
    end
    substance = flexmock('substance') do |s|
      s.should_receive(:language).and_return('substance_language')
    end
    active_agent = flexmock('active_agent') do |a|
      a.should_receive(:substance).and_return(substance)
      a.should_receive(:dose).and_return('dose')
    end
    composition = flexmock('composition') do |c|
      c.should_receive(:galenic_form).and_return(galenic_form)
      c.should_receive(:active_agents).and_return([active_agent])
    end
    atc_class = flexmock('atc_class') do |a|
      a.should_receive(:code).and_return('code')
    end
    @sequence = flexmock('sequence') do |s|
      s.should_receive(:seqnr).and_return(123)
      s.should_receive(:pointer)
      s.should_receive(:compositions).and_return([composition])
      s.should_receive(:atc_class).and_return(atc_class)
      s.should_receive(:has_patinfo?)
    end
    flexmock(@model) do |m|
      m.should_receive(:generic_type).and_return('generic_type')
      m.should_receive(:fachinfo_active?)
      m.should_receive(:has_fachinfo?)
      m.should_receive(:sequences).and_return({'key' => @sequence})
    end
    pointer = flexmock('pointer', :to_csv => "pointer")
    flexmock(@sequence, :pointer => pointer)
    @composite = ODDB::View::Admin::RegistrationComposite.new(@model, @session)
  end
  def test_registration_sequences
    assert_kind_of(ODDB::View::Admin::RegistrationSequences, @composite.registration_sequences(@model, @session))
  end
  def test_source
    package = flexmock('package') do |p|
      p.should_receive(:swissmedic_source).and_return('swissmedic_source')
    end
    flexmock(@sequence, :packages => {'key' => package})
    flexmock(@model, :packages => [package])
    assert_kind_of(HtmlGrid::Value, @composite.source(@model, @session))
  end
end
    end # Admin
  end # View
end # ODDB

