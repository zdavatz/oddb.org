#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Hospitals::TestHospital -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/global'

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/welcomehead'
require 'state/hospitals/hospital'
require 'state/hospitals/setpass'

module ODDB
  module State
    module Hospitals

class TestRootHospital <Minitest::Test
  include FlexMock::TestCase
  def setup
    @update  = flexmock('update', :user => 'user')
    @app     = flexmock('app', :update => @update)
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => {}
                       )
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
    @state   = ODDB::State::Hospitals::RootHospital.new(@session, @model)
    flexmock(@state, 
             :allowed?     => true,
             :unique_email => 'unique_email'
            )
  end
  def test_init
    assert_equal(ODDB::View::Hospitals::RootHospital, @state.init)
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
    assert_kind_of(ODDB::State::Hospitals::SetPass, @state.set_pass)
  end
end


    end # Hospitals
  end # State
end # ODDB

