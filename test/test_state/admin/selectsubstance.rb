#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestSelectSubstance -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/selectsubstance'

module ODDB
  module State
    module Admin

class TestSelectSubstance < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app', :update => 'update')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @substance = flexmock('substance', 
                          :pointer => 'pointer',
                          :name    => 'name'
                         )
    @pointer = flexmock('pointer', 
                        :is_a? => nil,
                        :resolve => @substance
                       )
    @session = flexmock('session', 
                        :app =>@app,
                        :lookandfeel => @lnf,
                        :user_input  => @pointer
                       )
    active_agent = flexmock('active_agent', 
                            :pointer => 'pointer',
                            :is_a?   => true,
                            :append  => 'append',
                            :inner_pointer => 'inner_pointer'
                           )
    user_input    = flexmock('user_input', :[] => [])
    @model   = flexmock('model', 
                        :active_agent => active_agent,
                        :user_input   => user_input,
                        :pointer      => 'pointer'
                       )
    @state   = ODDB::State::Admin::SelectSubstance.new(@session, @model)
    resolve_state = flexmock('resolve_state', :new => 'new')
    flexmock(@state, 
             :resolve_state => resolve_state,
             :unique_email  => 'unique_email'
            )
  end
  def test_update
    assert_equal('new', @state.update)
  end
  def test_update__invalid_data_error
    flexmock(@app, :update => @substance)
    flexmock(@pointer, :is_a? => true)
    assert_equal('new', @state.update)
  end
end

    end # Admin
  end # State
end # ODDB
