#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestRegistration -- oddb.org -- 15.12.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/registration'
require 'util/log'
require 'model/registration'
#require 'src/state/admin/wait_for_fachinfo'

module ODDB
  module State
    module Admin
      class WaitForFachinfo < State::Admin::Global; end
    end
  end
end

module ODDB
  module State
    module Admin

class TestRegistration <Minitest::Test
  include FlexMock::TestCase
  def setup 
    @pointer = flexmock('pointer', :+ => @pointer)
    @registration= flexmock('registration', 
                            :pointer => @pointer,
                            :company => 'company',
                            :iksnr => 'iksnr',
                            )
    @app     = flexmock('app', :registration => @registration)
    @lnf     = flexmock('lookandfeel', :event_url => 'event_url')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :app         => @app,
                        :persistent_user_input => 'persistent_user_input',
                       )
    @model   = flexmock('model', 
                        :fachinfo => 'fachinfo',
                        :carry   => 'carray'
                       )
    @reg     = ODDB::State::Admin::Registration.new(@session, @model)
  end
  def test_assign_fachinfo
    assert_kind_of(ODDB::State::Admin::AssignFachinfo, @reg.assign_fachinfo)
  end
  def test_get_fachinfo
    # This is a testcase of a private method
    flexmock(@app, :async => nil)
    flexmock(File, :open => nil)
    flexmock(FileUtils, :mkdir_p => nil)
    flexmock(@model, 
             :pointer => 'pointer',
             :iksnr   => 'iksnr'
            )
    fi_file = flexmock('fi_file', 
                       :read   => '%PDF',
                       :rewind => nil
                      )
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:language_select).and_return('language')
      s.should_receive(:user_input).once.with(:fachinfo_upload).and_return(fi_file)
    end
    assert_kind_of(ODDB::State::Admin::WaitForFachinfo, @reg.instance_eval('get_fachinfo')) 
  end
  def test_get_fachinfo__textinfo_update
    # This is a testcase of a private method
    flexmock(ODDB::TextInfoPlugin).new_instances do |t|
      t.should_receive(:import_fulltext)
    end
    flexmock(ODDB::Log).new_instances do |l|
      l.should_receive(:update_values)
      l.should_receive(:notify).and_return('notify')
    end
    flexmock(@model, :iksnr => 'iksnr')
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:language_select)
      s.should_receive(:user_input).once.with(:textinfo_update).and_return('text_info_update')
    end
    assert_kind_of(ODDB::State::Admin::Registration, @reg.instance_eval(('get_fachinfo')))
  end
  def test_get_fachinfo__updated_textinfo
    # This is a testcase of a private method
    flexmock(ODDB::TextInfoPlugin).new_instances do |t|
      t.should_receive(:import_fulltext)
      t.should_receive(:updated_fis).and_return(1)
      t.should_receive(:updated_pis).and_return(1)
    end
    flexmock(ODDB::Log).new_instances do |l|
      l.should_receive(:update_values)
      l.should_receive(:notify).and_return('notify')
    end
    flexmock(@model, :iksnr => 'iksnr')
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:language_select)
      s.should_receive(:user_input).once.with(:textinfo_update).and_return('text_info_update')
    end
    assert_kind_of(ODDB::State::Admin::Registration, @reg.instance_eval(('get_fachinfo')))
  end
  def test_get_fachinfo__updated_fachinfo
    # This is a testcase of a private method
    flexmock(ODDB::TextInfoPlugin).new_instances do |t|
      t.should_receive(:import_fulltext)
      t.should_receive(:updated_fis).and_return(1)
      t.should_receive(:updated_pis).and_return(0)
    end
    flexmock(ODDB::Log).new_instances do |l|
      l.should_receive(:update_values)
      l.should_receive(:notify).and_return('notify')
    end
    flexmock(@model, :iksnr => 'iksnr')
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:language_select)
      s.should_receive(:user_input).once.with(:textinfo_update).and_return('text_info_update')
    end
    assert_kind_of(ODDB::State::Admin::Registration, @reg.instance_eval(('get_fachinfo')))
  end
  def test_get_fachinfo__updated_patinfo
    # This is a testcase of a private method
    flexmock(ODDB::TextInfoPlugin).new_instances do |t|
      t.should_receive(:import_fulltext)
      t.should_receive(:updated_fis).and_return(0)
      t.should_receive(:updated_pis).and_return(1)
    end
    flexmock(ODDB::Log).new_instances do |l|
      l.should_receive(:update_values)
      l.should_receive(:notify).and_return('notify')
    end
    flexmock(@model, :iksnr => 'iksnr')
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:language_select)
      s.should_receive(:user_input).once.with(:textinfo_update).and_return('text_info_update')
    end
    assert_kind_of(ODDB::State::Admin::Registration, @reg.instance_eval(('get_fachinfo')))
  end
  def test_parse_fachinfo
    # This is a testcase of a private method
    file = flexmock('file', :read => nil)
    drb = flexmock('drb', :parse_fachinfo_type => 'result')
    flexmock(DRb::DRbObject, :new => drb)
    assert_equal('result', @reg.instance_eval('parse_fachinfo("type", file)'))
  end
  def test_parse_fachinfo__argument_error
    # This is a testcase of a private method
    flexmock(@lnf, :lookup => 'lookup')
    file = flexmock('file') do |f|
      f.should_receive(:read).and_raise(ArgumentError)
    end
    drb = flexmock('drb', :parse_fachinfo_type => 'result')
    flexmock(DRb::DRbObject, :new => drb)
    assert_kind_of(SBSM::ProcessingError, @reg.instance_eval('parse_fachinfo("type", file)'))
  end
  def test_parse_fachinfo__standard_error
    # This is a testcase of a private method
    flexmock(@lnf, :lookup => 'lookup')
    file = flexmock('file') do |f|
      f.should_receive(:read).and_raise(StandardError)
    end
    drb = flexmock('drb', :parse_fachinfo_type => 'result')
    flexmock(DRb::DRbObject, :new => drb)
    assert_kind_of(StandardError, @reg.instance_eval('parse_fachinfo("type", file)'))
  end
  def test_new_patent
    model   = flexmock('model', :iksnr => 'iksnr')
    pointer = flexmock('pointer', :resolve => model)
    flexmock(pointer, :+ => pointer)
    flexmock(@session, :user_input => pointer)
    flexmock(@reg, :resolve_state => nil)
    assert_kind_of(ODDB::State::Admin::Registration, @reg.new_patent)
  end
  def test_new_patent__resolve_state
    model   = flexmock('model', :iksnr => 'iksnr')
    pointer = flexmock('pointer', :resolve => model)
    flexmock(pointer, :+ => pointer)
    flexmock(@session, :user_input => pointer)
    klass   = flexmock('klass', :new => 'new')
    flexmock(@reg, :resolve_state => klass)
    assert_equal('new', @reg.new_patent)
  end
  def test_new_sequence
    model   = flexmock('model', 
                       :iksnr   => 'iksnr',
                       :company => 'company'
                      )
    pointer = flexmock('pointer', :resolve => model)
    flexmock(pointer, :+ => pointer)
    flexmock(@session, :user_input => pointer)
    flexmock(@reg, :resolve_state => nil)
    assert_kind_of(ODDB::State::Admin::Registration, @reg.new_sequence)
  end
  def test_new_sequence__resolve_state
    model   = flexmock('model', 
                       :iksnr   => 'iksnr',
                       :company => 'company'
                      )
    pointer = flexmock('pointer', :resolve => model)
    flexmock(pointer, :+ => pointer)
    flexmock(@session, :user_input => pointer)
    klass   = flexmock('klass', :new => 'new')
    flexmock(@reg, :resolve_state => klass)
    assert_equal('new', @reg.new_sequence)
  end
  def test_resolve_company
    company = flexmock('company', :oid => 'oid')
    flexmock(@session, 
             :user_input      => 'company_name',
             :company_by_name => company
            )
    assert_equal('oid', @reg.resolve_company({}))
  end
  def test_resolve_company__error
    flexmock(@session, 
             :user_input      => 'company_name',
             :company_by_name => nil
            )
    flexmock(@model, :company => nil)
    assert_kind_of(SBSM::ProcessingError, @reg.resolve_company({}))
  end
  def test_do_update
    indication = flexmock('indication', :pointer => 'pointer')
    flexmock(@app, 
             :indication_by_text => indication,
             :update             => 'update'
            )
    company = flexmock('company', :oid => 'oid')
    flexmock(@session, 
             :user_input      => {'key' => 'company_name'},
             :company_by_name => company
            )
    flexmock(@session, :user_input => {})
    flexmock(@reg, 
             :get_fachinfo => 'new_state',
             :unique_email => 'unique_email'
            )
    flexmock(@model, :pointer => 'pointer')
    assert_equal('new_state', @reg.do_update(['key']))
  end
  def test_do_update__error
    flexmock(@session, :user_input => 'user_input')
    flexmock(@model, :is_a? => true)
    flexmock(@reg, :error? => true)
    assert_equal(@reg, @reg.do_update(['key']))
  end
  def test_do_update__indication_empty
    flexmock(@app, 
             :indication_by_text => nil,
             :update             => 'update',
             :search_indications => ['indication']
            )
    company = flexmock('company', :oid => 'oid')
    flexmock(@session, 
             :user_input      => {'key' => 'company_name'},
             :company_by_name => company
            )
    flexmock(@session, :user_input => {'key' => 'value'})
    flexmock(@reg, 
             :get_fachinfo => 'new_state',
             :unique_email => 'unique_email'
            )
    flexmock(@model, :pointer => 'pointer')

    assert_equal('new_state', @reg.do_update(['key']))
  end
  def test_update
    flexmock(@session, :user_input => 'user_input')
    flexmock(@model, 
             :is_a?  => true,
             :append => nil
            )
    flexmock(@reg, :error? => true)
    flexmock(@app, :registration => nil)
    assert_equal(@reg, @reg.update)
  end
  def test_update__error
    flexmock(@session, :user_input => 'user_input')
    flexmock(@model, 
             :is_a?  => true,
             :append => nil
            )
    flexmock(@reg, 
             :error?                => true,
             :error_check_and_store => true
            )
    flexmock(@app, :registration => nil)
    assert_equal(@reg, @reg.update)
  end
  def test_update__duplicate_iksnr
    flexmock(@session, :user_input => 'user_input')
    flexmock(@model, 
             :is_a?  => true,
             :append => nil
            )
    flexmock(@reg, :error? => true)
    flexmock(@app, :registration => true)
    assert_equal(@reg, @reg.update)
  end
end

class TestCompanyRegistration <Minitest::Test
  include FlexMock::TestCase
  def setup
    @pointer = flexmock('pointer', :+ => @pointer)
    @registration= flexmock('registration', 
                            :pointer => @pointer,
                            :company => 'company',
                            :iksnr => 'iksnr',
                            )
    @app     = flexmock('app', :registration => @registration)
    @lnf     = flexmock('lookandfeel', :event_url => 'event_url')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :app         => @app,
                        :allowed?    => true,
                        :persistent_user_input => 'persistent_user_input',
                       )
    @model   = flexmock('model', 
                        :company => 'company',
                        :carry   => 'carray'
                       )
    @reg = ODDB::State::Admin::CompanyRegistration.new(@session, @model)
  end
  def test_init
    assert_equal(nil, @reg.init)
  end
  def test_allowed
    flexmock(@session, :allowed? => true)
    assert_equal(true, @reg.allowed?)
  end
  def test_new_patent
    flexmock(@session, :allowed? => true)
    model   = flexmock('model', :iksnr => 'iksnr')
    pointer = flexmock('pointer', :resolve => model)
    flexmock(pointer, :+ => pointer)
    flexmock(@session, :user_input => pointer)
    flexmock(@reg, :resolve_state => nil)

    assert_kind_of(ODDB::State::Admin::CompanyRegistration, @reg.new_patent)
  end
  def test_new_sequence
    flexmock(@session, :allowed? => true)
    model   = flexmock('model', 
                       :iksnr   => 'iksnr',
                       :company => 'company'
                      )
    pointer = flexmock('pointer', :resolve => model)
    flexmock(pointer, :+ => pointer)
    flexmock(@session, :user_input => pointer)
    flexmock(@reg, :resolve_state => nil)
    assert_kind_of(ODDB::State::Admin::Registration, @reg.new_sequence)

  end
  def test_resolve_company
    flexmock(@model, :is_a? => true)
    flexmock(@session, :"user.model.oid" => "user.model.oid")
    hash = {}
    assert_equal('user.model.oid', @reg.resolve_company(hash))
    expected = {:company => 'user.model.oid'}
    assert_equal(expected, hash)
  end
  def test_update
    flexmock(@session, :allowed? => true)
    flexmock(@session, :user_input => 'user_input')
    flexmock(@model, 
             :is_a?  => true,
             :append => nil
            )
    flexmock(@reg, :error? => true)
    flexmock(@app, :registration => nil)
    assert_equal(@reg, @reg.update)
  end
end

class TestResellerRegistration <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :event_url => 'event_url')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :app         => @app
                       )
    @company = flexmock('company')
    @model   = flexmock('model', :company => @company)

    # for get_fachinfo
    flexmock(@app, :async => nil)
    flexmock(File, :open => nil)
    flexmock(FileUtils, :mkdir_p => nil)
    flexmock(@model, 
             :pointer => 'pointer',
             :iksnr   => 'iksnr'
            )
    @reg     = ODDB::State::Admin::ResellerRegistration.new(@session, @model)
  end
  def test_update
    flexmock(@company, :invoiceable? => true)
    fi_file = flexmock('fi_file', 
                       :read   => '%PDF',
                       :rewind => nil
                      )
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:language_select).and_return('language')
      s.should_receive(:user_input).once.with(:fachinfo_upload).and_return(fi_file)
    end
    assert_kind_of(ODDB::State::Admin::WaitForFachinfo, @reg.update)
  end
  def test_update__else
    flexmock(@company, 
             :invoiceable? => false,
             :pointer      => 'pointer'
            )
    newstate = flexmock('newstate', :errors => {})
    klass    = flexmock('klass', :new => newstate)
    flexmock(@reg, :resolve_state => klass)
    assert_equal(newstate, @reg.update)
  end
end
    end # Admin
  end # State
end # ODDB
