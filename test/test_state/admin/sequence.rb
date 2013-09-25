#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestSequence -- oddb.org -- 14.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/sequence'
require 'state/global'

class TestResellerSequence <Minitest::Test  
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel')
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(@lookandfeel)
      s.should_receive(:assign_patinfo)
    end
    @model = flexmock('model')
    @sequence = ODDB::State::Admin::ResellerSequence.new(@session, @model)
  end
  def test_get_patinfo_input__html_upload
    html_file = flexmock('html_file', :read => nil)
    patinfo = flexmock('patinfo', :pointer => nil)
    app = flexmock('app', :update => patinfo)
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:html_upload).and_return(html_file)
      s.should_receive(:user_input).once.with(:language_select).and_return('language')
      s.should_receive(:app).and_return(app)
    end
    flexmock(@sequence, :parse_patinfo => 'document')
    flexmock(@model) do |m|
      m.should_receive(:patinfo).and_return(patinfo)
      m.should_receive(:pdf_patinfo=)
    end
    assert_equal(@sequence, @sequence.get_patinfo_input({}))
  end
  def test_get_patinfo_input__html_upload_nil_model_patinfo
    html_file = flexmock('html_file', :read => nil)
    patinfo = flexmock('patinfo', :pointer => nil)
    app = flexmock('app', :update => patinfo)
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:html_upload).and_return(html_file)
      s.should_receive(:user_input).once.with(:language_select).and_return('language')
      s.should_receive(:app).and_return(app)
    end
    flexmock(@sequence, :parse_patinfo => 'document')
    flexmock(@model) do |m|
      m.should_receive(:patinfo)
      m.should_receive(:pdf_patinfo=)
    end
    assert_equal(@sequence, @sequence.get_patinfo_input({}))
  end
  def test_get_patinfo_input__patinfo_upload
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:html_upload)
      s.should_receive(:user_input).once.with(:patinfo_upload).and_return('pi_file')
    end
    pointer = flexmock('pointer') do |p|
      p.should_receive(:skeleton).and_return([:company])  # This is the key point
    end
    company = flexmock('company') do |c|
      c.should_receive(:invoiceable?)
      c.should_receive(:pointer).and_return(pointer)
    end
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(company)
    end
    assert_kind_of(ODDB::State::Companies::Company, @sequence.get_patinfo_input({}))
  end
  def test_get_patinfo_input__patinfo_upload__invoiceable
    pi_file = flexmock('pi_file') do |p|
      p.should_receive(:read).and_return('%PDF')
      p.should_receive(:rewind)
    end
    app = flexmock('app') do |a|
      a.should_receive(:create)
      a.should_receive(:update)
    end
    skip("Somebody moved Migel around without updating the corresponding test, here")
    flexmock(@lookandfeel) do |l|
      l.should_receive(:lookup)
    end
    user = flexmock('user') do |u|
      u.should_receive(:name).and_return('name')
    end
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:html_upload)
      s.should_receive(:user_input).once.with(:patinfo_upload).and_return(pi_file)
      s.should_receive(:app).and_return(app)
      s.should_receive(:user).and_return(user)
    end
    pointer = flexmock('pointer') do |p|
    end
    company = flexmock('company') do |c|
      c.should_receive(:invoiceable?).and_return(true)
      c.should_receive(:pointer).and_return(pointer)
    end
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(company)
      m.should_receive(:iksnr).and_return('iksnr')
      m.should_receive(:seqnr).and_return('seqnr')
      m.should_receive(:pdf_patinfo=)
      m.should_receive(:name).and_return('name')
      m.should_receive(:pointer).and_return('pointer')
    end
    flexmock(FileUtils, :mkdir_p => nil)
    flexmock(File) do |k|
      k.should_receive(:new).and_return(flexmock('file') do |f|
        f.should_receive(:write)
        f.should_receive(:close)
      end)
    end
    assert_kind_of(ODDB::State::Admin::AssignPatinfo, @sequence.get_patinfo_input({}))
  end
  def test_get_patinfo_input__patinfo_upload__invoiceable__else
    pi_file = flexmock('pi_file') do |p|
      p.should_receive(:read)
    end
    app = flexmock('app') do |a|
    end
    flexmock(@lookandfeel) do |l|
    end
    user = flexmock('user') do |u|
    end
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:html_upload)
      s.should_receive(:user_input).once.with(:patinfo_upload).and_return(pi_file)
    end
    pointer = flexmock('pointer') do |p|
    end
    company = flexmock('company') do |c|
      c.should_receive(:invoiceable?).and_return(true)
    end
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(company)
    end
    skip("Somebody moved Migel around without updating the corresponding test, here")
    assert_equal(@sequence, @sequence.get_patinfo_input({}))
  end
  def test_get_patinfo_input__patinfo_delete
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:html_upload)
      s.should_receive(:user_input).once.with(:patinfo_upload)
      s.should_receive(:user_input).once.with(:patinfo).and_return('delete')
    end
    assert_equal(@sequence, @sequence.get_patinfo_input({}))
  end
  def test_get_patinfo_input__nothing
    flexmock(@session, :user_input => nil)
    assert_equal(@sequence, @sequence.get_patinfo_input({}))
  end
  def test_parse_patinfo__error
    assert_equal(nil, @sequence.parse_patinfo('src'))
  end
  def test_store_slate_item
    app = flexmock('app') do |a|
      a.should_receive(:create)
      a.should_receive(:update).and_return('update')
    end
    user = flexmock('user') do |u|
      u.should_receive(:name).and_return('name')
    end
    flexmock(@session) do |s|
      s.should_receive(:app).and_return(app)
      s.should_receive(:user).and_return(user)
    end
    flexmock(@lookandfeel) do |l|
      l.should_receive(:lookup).and_return('unit')
    end
    flexmock(@model) do |m|
      m.should_receive(:iksnr).and_return('iksnr')
      m.should_receive(:seqnr).and_return('seqnr')
      m.should_receive(:name).and_return('name')
      m.should_receive(:pointer)
    end
    assert_equal('update', @sequence.store_slate_item(Time.local(2011,2,3), 'type'))
  end
  def test_store_slate
    app = flexmock('app') do |a|
      a.should_receive(:create)
      a.should_receive(:update).and_return('update')
    end
    user = flexmock('user') do |u|
      u.should_receive(:name).and_return('name')
    end
    flexmock(@session) do |s|
      s.should_receive(:app).and_return(app)
      s.should_receive(:user).and_return(user)
    end
    flexmock(@lookandfeel) do |l|
      l.should_receive(:lookup).and_return('unit')
    end
    flexmock(@model) do |m|
      m.should_receive(:iksnr).and_return('iksnr')
      m.should_receive(:seqnr).and_return('seqnr')
      m.should_receive(:name).and_return('name')
      m.should_receive(:pointer)
    end
    assert_equal('update', @sequence.store_slate)
  end
  def test_update
    app = flexmock('app') do |a|
      a.should_receive(:update)
    end
    user = flexmock('user')
    flexmock(@session) do |s|
      s.should_receive(:user_input)
      s.should_receive(:app).and_return(app)
      s.should_receive(:user).and_return(user)
    end
    flexmock(@model) do |m|
      m.should_receive(:pointer)
    end
    assert_equal(@sequence, @sequence.update)
  end
end

class TestSequence <Minitest::Test
  include FlexMock::TestCase
  def setup
    ptr      = flexmock('ptr', :skeleton => 'skeleton')
    pointer      = flexmock('pointer', :+ => ptr)
    sequence     = flexmock('sequence', :pointer => pointer, :iksnr => 'iksnr', :name_base => 'name_base')
    registration = flexmock('registration', :sequence => sequence)
    @app = flexmock('app', :registration => registration)
    @session = flexmock('session', :app => @app, :persistent_user_input => [])
    @model = flexmock('model', :pointer => 'pointer', :seqnr => '1')
    @sequence = ODDB::State::Admin::Sequence.new(@session, @model)
  end
  def test_delete
    pointer = flexmock('pointer', :skeleton => [:company])
    registration = flexmock('registration', :pointer => pointer) 
    flexmock(@model) do |m|
      m.should_receive(:parent).and_return(registration)
      m.should_receive(:pointer)
    end
    flexmock(@app, :delete => nil)
    assert_kind_of(ODDB::State::Companies::Company, @sequence.delete)
  end
  def test_new_active_agent
    pointer = flexmock('pointer') do |p|
      p.should_receive(:resolve).and_return(@model)
      p.should_receive(:skeleton)
    end
    flexmock(pointer, :+ => pointer)
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return(pointer)
    end
    flexmock(@model) do |m|
      m.should_receive(:iksnr)
      m.should_receive(:name_base)
    end
    assert_equal(@sequence, @sequence.new_active_agent)
  end
  def test_new_active_agent__resolve_state
    pointer = flexmock('pointer') do |p|
      p.should_receive(:resolve).and_return(@model)
      p.should_receive(:skeleton).and_return([:company])
    end
    flexmock(pointer, :+ => pointer)
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return(pointer)
    end
    flexmock(@model) do |m|
      m.should_receive(:iksnr)
      m.should_receive(:name_base)
    end
    assert_kind_of(ODDB::State::Companies::Company, @sequence.new_active_agent)
  end
  def test_new_package
    pointer = flexmock('pointer') do |p|
      p.should_receive(:resolve).and_return(@model)
      p.should_receive(:skeleton)
    end
    flexmock(pointer, :+ => pointer)
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return(pointer)
    end
    flexmock(@model) do |m|
      m.should_receive(:iksnr)
      m.should_receive(:name_base)
    end
    assert_equal(@sequence, @sequence.new_package)
  end
  def test_new_package__resolve_state
    pointer = flexmock('pointer') do |p|
      p.should_receive(:resolve).and_return(@model)
      p.should_receive(:skeleton).and_return([:company])
    end
    flexmock(pointer, :+ => pointer)
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return(pointer)
    end
    flexmock(@model) do |m|
      m.should_receive(:iksnr)
      m.should_receive(:name_base)
    end
    assert_kind_of(ODDB::State::Admin::Sequence, @sequence.new_package)
  end
  def test_check_model__no_error
    flexmock(@model, 
             :reg => 'reg',
             :seq => 'seq'
            )
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return('pointer')
      s.should_receive(:allowed?).and_return(true)
    end
    assert_equal(nil, @sequence.check_model)
  end
  def test_check_model__e_state_expired
    flexmock(@model, :pointer => 'pointer1')
    flexmock(@session, 
             :user_input => {:reg => nil},
             :allowed?   => true
            )
    @sequence.check_model
    result = @sequence.errors[:pointer]
    assert_kind_of(SBSM::ProcessingError, result)
    assert_equal('e_state_expired', result.message)
  end
  def test_check_model__e_not_allowed
    flexmock(@model, :pointer => 'pointer')
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return('pointer')
      s.should_receive(:allowed?).and_return(false)
    end
    result = @sequence.check_model
    assert_kind_of(SBSM::ProcessingError, result)
    assert_equal('e_not_allowed', result.message)
  end
  def test_mandatory_violation
    # This is a method defined in SBSM::State, which is the superclass of State::Global
    # This test is made just for the understanding of this method.
    value = nil
    assert_equal(true, @sequence.instance_eval('mandatory_violation(value)'))
    value = []
    assert_equal(true, @sequence.instance_eval('mandatory_violation(value)'))
    value = {}
    assert_equal(true, @sequence.instance_eval('mandatory_violation(value)'))
    value = "abc"
    assert_equal(false, @sequence.instance_eval('mandatory_violation(value)'))
  end
  def test_error_check_and_store__no_error
    # This is a method defined in SBSM::State
    # This test is made just for the understanding of this method.
    mandatory = []
    assert_equal(nil, @sequence.error_check_and_store('key', ['value'], mandatory))
  end
  def test_user_input
    # This is a method defined in SBSM::State
    # This test is made just for the understanding of this method.
    keys = [:pointer, :composition]
    mandatory = [:pointer, :composition]
    value = {'key' => 'value'}
    flexmock(@session, :user_input => value)
    assert_equal(value, @sequence.user_input(keys, mandatory))
  end
  def test_ajax_create_active_agent__error
    value = {:pointer => 'pointer', :composition => '0'}
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return(value)
      s.should_receive(:allowed?).and_return(true)
    end
    composition = flexmock('composition', :active_agents => [])
    flexmock(@model) do |m|
      m.should_receive(:pointer).and_return(value)
      m.should_receive(:compositions).and_return([composition])
    end
    assert_kind_of(ODDB::State::Admin::AjaxActiveAgents, @sequence.ajax_create_active_agent)
  end
  def test_ajax_create_composition
    flexmock(@model, :pointer => 'pointer')
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return('pointer')
      s.should_receive(:allowed?).and_return(true)
    end
    flexmock(@model) do |m|
      m.should_receive(:compositions).and_return([])
    end
    flexmock(ODBA.cache) do |c|
      c.should_receive(:next_id).and_return(123)
    end
    assert_kind_of(ODDB::State::Admin::AjaxCompositions, @sequence.ajax_create_composition)
  end
  def test_ajax_delete_active_agent
    value = {:pointer => 'pointer', :active_agent => 'active_agent', :composition => '0'}
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return(value)
      s.should_receive(:allowed?).and_return(true)
    end
    flexmock(@app, :delete => nil)
    active_agent = flexmock('active_agent', :pointer => nil)
    composition = flexmock('composition', :active_agents => [active_agent])
    flexmock(@model) do |m|
      m.should_receive(:pointer).and_return(value)
      m.should_receive(:compositions).and_return([composition])
    end
    assert_kind_of(ODDB::State::Admin::AjaxActiveAgents, @sequence.ajax_delete_active_agent)
  end
  def test_ajax_delete_composition
    value = {:pointer => 'pointer', :composition => '0'}
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return(value)
      s.should_receive(:allowed?).and_return(true)
    end
    composition = flexmock('composition', :pointer => nil)
    flexmock(@model) do |m|
      m.should_receive(:pointer).and_return(value)
      m.should_receive(:compositions).and_return([composition])
    end
    flexmock(@app, :delete => nil)
    assert_kind_of(ODDB::State::Admin::AjaxCompositions, @sequence.ajax_delete_composition)
  end
  def test_update_compositions
    substance = flexmock('substance')
    substances = {0 => substance} 
    substances_set = {0 => substances}
    input = {
      :substance    => substances_set,
      :dose         => [['dose']],
      :galenic_form => ['galenic_form'],
    }
    active_agent = flexmock('active_agent') do |a|
      a.should_receive(:pointer).and_return('agent_pointer')
      a.should_receive(:substance)
    end
    composition = flexmock('composition') do |c|
      c.should_receive(:pointer).and_return('comp_pointer')
      c.should_receive(:active_agents).and_return([active_agent])
    end
    flexmock(@model) do |m|
      m.should_receive(:compositions).and_return([composition])
    end
    flexmock(@session, :user => flexmock('user'))
    flexmock(@app) do |a|
      a.should_receive(:update).once.with(
        'comp_pointer', {:galenic_form => 'galenic_form'}, nil
        ).and_return(composition)
      a.should_receive(:update).once.with(ODDB::Persistence::Pointer, Hash)
      a.should_receive(:update).once.with(
        'agent_pointer', {:substance => substance, :dose => 'dose'}, nil
        ).and_return(active_agent)
      a.should_receive(:substance)
    end
    assert_equal(nil, @sequence.update_compositions(input))
  end
  def test_update_compositions__nil
    assert_equal(nil, @sequence.update_compositions({}))
  end
  def test_update
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return('seqnr')
      s.should_receive(:language).and_return('language')
      s.should_receive(:user)
    end
    flexmock(@app) do |a|
      a.should_receive(:update)
    end
    company = flexmock('company') do |c|
      c.should_receive(:pointer)
    end
    parent = flexmock('parent') do |p|
      p.should_receive(:sequence)
    end
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(company)
      m.should_receive(:pointer)
      m.should_receive(:is_a?).and_return(true)
      m.should_receive(:parent).and_return(parent)
      m.should_receive(:append)
      m.should_receive(:carry)
    end
    # Actually, this should not be replaced by flexmock
    flexmock(@sequence) do |s|
      s.should_receive(:get_patinfo_input).and_return('get_patinfo_input')
    end
    assert_equal('get_patinfo_input', @sequence.update)
  end
  def test_update__atc_class
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:seqnr).and_return('seqnr')
      s.should_receive(:user_input).once.with(:atc_descr)
      keys = [
          :composition_text,
          :dose,
          :export_flag,
          :name_base,
          :name_descr,
          :longevity,
          :substance,
          :galenic_form,
          :activate_patinfo,
          :deactivate_patinfo,
          :sequence_date,
      ]
      s.should_receive(:user_input).once.with(*keys)
      atc_input = {:code => 'atc_code'}
      s.should_receive(:user_input).once.with(:code).and_return(atc_input)
      s.should_receive(:user_input).once.with(:regulatory_email)
      s.should_receive(:user_input).once.with(:composition_text, :dose, :export_flag, :name_base, :name_descr, :longevity, :substance, :galenic_form, :activate_patinfo, :deactivate_patinfo, :sequence_date, :division_divisable, :division_dissolvable, :division_crushable, :division_openable, :division_notes, :division_source) 
      s.should_receive(:user_input).once.with(:composition_text)       
      s.should_receive(:language).and_return('language')
      s.should_receive(:user)            
    end
    skip("This text probably fails because flexmock can only match 11 arguments")
    flexmock(@app) do |a|
      a.should_receive(:update)
      a.should_receive(:atc_class).and_return('atc_class')
    end
    company = flexmock('company') do |c|
      c.should_receive(:pointer)
    end
    parent = flexmock('parent') do |p|
      p.should_receive(:sequence)
    end
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(company)
      m.should_receive(:pointer)
      m.should_receive(:is_a?).and_return(true)
      m.should_receive(:parent).and_return(parent)
      m.should_receive(:append)
      m.should_receive(:carry)
    end
    # Actually, this should not be replaced by flexmock
    flexmock(@sequence) do |s|
      s.should_receive(:get_patinfo_input).and_return('get_patinfo_input')
    end
    assert_equal('get_patinfo_input', @sequence.update)
  end
  def test_update__e_unknown_atc_class
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:seqnr).and_return('seqnr')
      s.should_receive(:user_input).once.with(:atc_descr)
      keys = [
          :composition_text,
          :dose,
          :export_flag,
          :name_base,
          :name_descr,
          :longevity,
          :substance,
          :galenic_form,
          :activate_patinfo,
          :deactivate_patinfo,
          :sequence_date,
      ]
      s.should_receive(:user_input).once.with(*keys)
      atc_input = {:code => 'atc_code'}
      s.should_receive(:user_input).once.with(:code).and_return(atc_input)
      s.should_receive(:user_input).once.with(:regulatory_email)
      s.should_receive(:language).and_return('language')
      s.should_receive(:user_input).with(:composition_text, :dose, :export_flag, :name_base, :name_descr, :longevity, :substance, :galenic_form, :activate_patinfo, :deactivate_patinfo, :sequence_date, :division_divisable, :division_dissolvable, :division_crushable, :division_openable, :division_notes, :division_source)
      s.should_receive(:user)
    end
    skip("This text probably fails because flexmock can only match 11 arguments")
    flexmock(@app) do |a|
      a.should_receive(:update)
      a.should_receive(:atc_class)
    end
    company = flexmock('company') do |c|
      c.should_receive(:pointer)
    end
    parent = flexmock('parent') do |p|
      p.should_receive(:sequence)
    end
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(company)
      m.should_receive(:pointer)
      m.should_receive(:is_a?).and_return(true)
      m.should_receive(:parent).and_return(parent)
      m.should_receive(:append)
      m.should_receive(:carry)
    end
    # Actually, this should not be replaced by flexmock
    flexmock(@sequence) do |s|
      s.should_receive(:get_patinfo_input).and_return('get_patinfo_input')
    end
    assert_equal('get_patinfo_input', @sequence.update)
  end
  def test_update__error__runtime_error
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return(RuntimeError.new)
      s.should_receive(:language).and_return('language')
      s.should_receive(:user)
    end
    flexmock(@app) do |a|
      a.should_receive(:update)
    end
    company = flexmock('company') do |c|
      c.should_receive(:pointer)
    end
    parent = flexmock('parent') do |p|
      p.should_receive(:sequence)
    end
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(company)
      m.should_receive(:pointer)
      m.should_receive(:is_a?).and_return(true)
      m.should_receive(:parent).and_return(parent)
      m.should_receive(:append)
      m.should_receive(:carry)
    end
    # Actually, this should not be replaced by flexmock
    flexmock(@sequence) do |s|
      s.should_receive(:get_patinfo_input).and_return('get_patinfo_input')
    end
    assert_equal(@sequence, @sequence.update)
  end
  def test_update__error__seqnr_empty
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return('')
      s.should_receive(:language).and_return('language')
      s.should_receive(:user)
    end
    flexmock(@app) do |a|
      a.should_receive(:update)
    end
    company = flexmock('company') do |c|
      c.should_receive(:pointer)
    end
    parent = flexmock('parent') do |p|
      p.should_receive(:sequence)
    end
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(company)
      m.should_receive(:pointer)
      m.should_receive(:is_a?).and_return(true)
      m.should_receive(:parent).and_return(parent)
      m.should_receive(:append)
      m.should_receive(:carry)
    end
    # Actually, this should not be replaced by flexmock
    flexmock(@sequence) do |s|
      s.should_receive(:get_patinfo_input).and_return('get_patinfo_input')
    end
    assert_equal(@sequence, @sequence.update)
  end
  def test_update__error__e_duplicate_seqnr
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return('seqnr')
      s.should_receive(:language).and_return('language')
      s.should_receive(:user)
    end
    flexmock(@app) do |a|
      a.should_receive(:update)
    end
    company = flexmock('company') do |c|
      c.should_receive(:pointer)
    end
    parent = flexmock('parent') do |p|
      p.should_receive(:sequence).and_return(true)
    end
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(company)
      m.should_receive(:pointer)
      m.should_receive(:is_a?).and_return(true)
      m.should_receive(:parent).and_return(parent)
      m.should_receive(:append)
      m.should_receive(:carry)
    end
    # Actually, this should not be replaced by flexmock
    flexmock(@sequence) do |s|
      s.should_receive(:get_patinfo_input).and_return('get_patinfo_input')
    end
    assert_equal(@sequence, @sequence.update)
  end
  def test_store_slate
    # This is a private method test
    flexmock(@app) do |a|
      a.should_receive(:create)
      a.should_receive(:update)
    end
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:lookup)
    end
    user = flexmock('user') do |u|
      u.should_receive(:name).and_return('name')
    end
    flexmock(@session) do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
      s.should_receive(:user).and_return(user)
    end
    flexmock(@model) do |m|
      m.should_receive(:iksnr).and_return('iksnr')
      m.should_receive(:seqnr).and_return('seqnr')
      m.should_receive(:name).and_return('name')
      m.should_receive(:pointer).and_return('pointer')
    end
    assert_equal(nil, @sequence.instance_eval('store_slate'))
  end
  def test_atc_request
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:_event_url)
    end
    flexmock(@session) do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
    end
    company = flexmock('company') do |c|
      c.should_receive(:regulatory_email).and_return('regulatory_email')
    end
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(company)
      m.should_receive(:name_base).and_return('name_base')
      m.should_receive(:iksnr).and_return('iksnr')
      m.should_receive(:packages).and_return({'key' => 'package'})
      m.should_receive(:pointer).and_return('pointer')
      m.should_receive(:atc_request_time=)
      m.should_receive(:odba_isolated_store)
    end
    smtp = flexmock('smpt') do |s|
      s.should_receive(:sendmail)
    end
    flexmock(Net::SMTP) do |s|
      s.should_receive(:start).and_yield(smtp)
    end
    assert_equal(@sequence, @sequence.atc_request)
  end
end

class TestCompanySequence <Minitest::Test
  include FlexMock::TestCase
  class StubPointer
    attr_writer :model
    def resolve(app)
      @model ||= StubResolved.new
    end
    def +(other)
      self
    end
    def skeleton
      'skeleton'
    end
  end
  
  def setup
    pointer = StubPointer.new
    sequence = flexmock('sequence', :pointer => pointer, :iksnr => 'iksnr', :name_base => 'name_base')
    registration = flexmock('registration', :sequence => sequence)
    @app = flexmock('app', :registration => registration)
    @session = flexmock('session') do |s|
      s.should_receive(:persistent_user_input).and_return('nothing')
      s.should_receive(:app).and_return(@app)
    end
    @model = flexmock('model')
    @sequence = ODDB::State::Admin::CompanySequence.new(@session, @model)
  end
  def test_init
    flexmock(@session, :allowed? => false)
    assert_equal(ODDB::View::Admin::Sequence, @sequence.init)
  end
  def test_delete
    pointer = flexmock('pointer', :skeleton => [:company])
    parent = flexmock('parent', :pointer => pointer)
    flexmock(@model) do |m|
      m.should_receive(:parent).and_return(parent)
      m.should_receive(:pointer).and_return(pointer)
    end
    flexmock(@app, :delete => nil)
    flexmock(@session, :allowed? => true)
    assert_kind_of(ODDB::State::Companies::Company, @sequence.delete)
  end
  def test_delete__nil
    flexmock(@session, :allowed? => nil)
    assert_equal(nil, @sequence.delete)
  end
  def test_new_active_agent
    flexmock(@session, :allowed? => true)
    pointer = flexmock('pointer') do |p|
      p.should_receive(:resolve).and_return(@model)
      p.should_receive(:skeleton)
    end
    flexmock(pointer, :+ => pointer)
    flexmock(@session, :user_input => pointer)
    flexmock(@model) do |m|
      m.should_receive(:iksnr)
      m.should_receive(:name_base)
      m.should_receive(:user_input)
    end
    assert_equal(@sequence, @sequence.new_active_agent)
  end
  def test_new_package
    flexmock(@session, :allowed? => true)
    pointer = flexmock('pointer') do |p|
      p.should_receive(:resolve).and_return(@model)
      p.should_receive(:skeleton)
    end
    flexmock(pointer, :+ => pointer)
    flexmock(@session, :user_input => pointer)
    flexmock(@model) do |m|
      m.should_receive(:iksnr)
      m.should_receive(:name_base)
    end
    assert_equal(@sequence, @sequence.new_package)
  end
  def test_update
    flexmock(@session, :allowed? => true)
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return('seqnr')
      s.should_receive(:language).and_return('language')
      s.should_receive(:user)
    end
    flexmock(@app, :update => nil)
    company = flexmock('company', :pointer => nil)
    parent = flexmock('parent', :sequence => nil)
    flexmock(@model) do |m|
      m.should_receive(:company).and_return(company)
      m.should_receive(:pointer)
      m.should_receive(:is_a?).and_return(true)
      m.should_receive(:parent).and_return(parent)
      m.should_receive(:append)
      m.should_receive(:carry)
    end
    # Actually, this should not be replaced by flexmock
    flexmock(@sequence, :get_patinfo_input => 'get_patinfo_input')
    assert_equal('get_patinfo_input', @sequence.update)
  end
  def test_store_slate
    flexmock(@app, 
             :create => nil,
             :update => nil
            )
    lookandfeel = flexmock('lookandfeel', :lookup => nil)
    user = flexmock('user', :name => 'name')
    flexmock(@session, 
            :lookandfeel => lookandfeel,
            :user        => user
            )
    flexmock(@model, 
             :iksnr => 'iksnr', 
             :seqnr => 'seqnr',
             :name  => 'name',
             :pointer => 'pointer'
            )
    assert_equal(nil, @sequence.store_slate)
  end
end
