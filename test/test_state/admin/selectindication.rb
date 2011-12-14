#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestSelectIndication -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/selectindication'

module ODDB
  module State
    module Admin

module SelectIndicationMethods
  class TestSelection < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @registration = flexmock('registration', :pointer => 'pointer')
      @selection = ODDB::State::Admin::SelectIndicationMethods::Selection.new('user_input', 'selection', @registration)
    end
    def test_pointer
      assert_equal('pointer', @selection.pointer)
    end
    def test_structural_ancestors
      flexmock(@registration, :structural_ancestors => 'structural_ancestors')
      app = flexmock('app')
      assert_equal('structural_ancestors', @selection.structural_ancestors(app))
    end
    def test_new_indication
      assert_kind_of(ODDB::Persistence::CreateItem, @selection.new_indication)
    end
  end
end # SelectIndicationMethods

class TestSelectIndication < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app        = flexmock('app', :update => 'update')
    @lnf        = flexmock('lookandfeel', :lookup => 'lookup')
    indication  = flexmock('indication', :pointer => 'pointer')
    pointer     = flexmock('pointer', 
                           :resolve  => indication,
                           :skeleton => [:create]
                          )
    @session    = flexmock('session', 
                           :app => @app,
                           :lookandfeel => @lnf,
                           :user_input  => pointer,
                           :language    => 'language'
                          )
    @model      = flexmock('model', 
                           :user_input => 'user_input',
                           :pointer    => 'pointer'
                          )
    @indication = ODDB::State::Admin::SelectIndication.new(@session, @model)
    flexmock(@indication, :unique_email => 'unique_email')
  end
  def test_update
    assert_kind_of(ODDB::State::Admin::Registration, @indication.update)
  end
  def test_update__error
    flexmock(@indication, :error? => true)
    assert_equal(@indication, @indication.update)
  end
end
    end # Admin
  end # State
end # ODDB
