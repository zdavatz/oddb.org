#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/global'

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/welcomehead'
require 'state/pharmacies/setpass'
require 'state/pharmacies/pharmacy'

module ODDB
  module State
    module Pharmacies

class TestRootPharmacy <Minitest::Test
  include FlexMock::TestCase
  def setup
    @update  = flexmock('update', :user => 'user')
    @app     = flexmock('app', :update => @update)
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session',
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => {}
                       ).by_default
    address = flexmock('address',
                       :type=  => nil,
                       :title= => nil,
                       :name=  => nil,
                       :fon=   => nil,
                       :fax=   => nil,
                       :address=  => nil,
                       :location= => nil,
                       :canton=   => nil,
                       :additional_lines= => nil
                      )
    @model   = flexmock('model',
                        :address => address,
                        :pointer => 'pointer'
                       )
    @state   = ODDB::State::Pharmacies::RootPharmacy.new(@session, @model)
    flexmock(@state,
             :allowed?     => true,
             :unique_email => 'unique_email'
            )
  end
  def test_init
    assert_equal(ODDB::View::Pharmacies::RootPharmacy, @state.init)
  end
  def test_user_or_creator
    flexmock(@model, :user => nil)
    assert_kind_of(ODDB::Persistence::CreateItem, @state.instance_eval('user_or_creator'))
  end
  def test_do_update
    flexmock(@session, :user_input => {:name => 'name'})
    assert_equal(@update, @state.instance_eval('do_update'))
  end
  def test_update
    flexmock(@session, :user_input => {:name => 'name'})
    assert_equal(@state, @state.update)
  end
  def test_set_pass
    flexmock(@session, :user_input => {:name => 'name'})
    assert_kind_of(ODDB::State::Pharmacies::SetPass, @state.set_pass)
  end
end


    end # Pharmacies
  end # State
end # ODDB

