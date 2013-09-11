#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestSlEntry -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/slentry'

module ODDB
  module State
    module Admin

class TestSlEntry < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app', :delete => 'delete')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf
                       )
    @model   = flexmock('model', 
                        :parent  => 'package',
                        :pointer => 'pointer'
                       )
    @state   = ODDB::State::Admin::SlEntry.new(@session, @model)
  end
  def test_delete
    assert_kind_of(ODDB::State::Admin::Package, @state.delete)
  end
  def test_update
    package  = flexmock('package', 
                        :update  => 'update',
                        :pointer => 'pointer'
                       )
    sl_entry = flexmock('sl_entry', :parent => package)
    flexmock(@app, :update => sl_entry)
    flexmock(@session, :user_input => ['user_input'])
    flexmock(@state, :unique_email => 'unique_email')
    assert_equal(@state, @state.update)
  end
end

class TestCompanySlEntry < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :allowed? => nil
                       )
    @model   = flexmock('model', :parent => 'parent')
    @state   = ODDB::State::Admin::CompanySlEntry.new(@session, @model)
  end
  def test_init
    assert_equal(ODDB::View::Admin::SlEntry, @state.init)
  end
  def test_delete
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :allowed? => true)
    @model   = flexmock('model', :parent => 'parent')
    @state   = ODDB::State::Admin::CompanySlEntry.new(@session, @model)
    flexmock(@model, :pointer => 'pointer')
    flexmock(@app, :delete => 'delete')
    assert_kind_of(ODDB::State::Admin::Package, @state.delete)
  end
  def test_update
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :allowed? => true)
    @model   = flexmock('model', :parent => 'parent')
    @state   = ODDB::State::Admin::CompanySlEntry.new(@session, @model)
    package  = flexmock('package', 
                        :update  => 'update',
                        :pointer => 'pointer'
                       )
    sl_entry = flexmock('sl_entry', :parent => package)
    flexmock(@app, :update => sl_entry)
    flexmock(@session, 
             :allowed?   => true,
             :user_input => ['user_input'],
            )
    flexmock(@model, :pointer => 'pointer')
    flexmock(@state, :unique_email => 'unique_email')
    assert_equal(@state, @state.update)
  end
end

    end # Admin
  end # State
end # ODDB
