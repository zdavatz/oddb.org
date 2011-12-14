#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::TestSetPass -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'state/global'

require 'test/unit'
require 'flexmock'
require 'state/setpass'

module ODDB 
  module State

class StubSetPass
  include ODDB::State::SetPass
  def initialize(session, model)
    @model = model
    @session = session
    @lookandfeel = session.lookandfeel
    @errors = {}
  end
  def user_input(keys1, keys2)
    {}
  end
end

class TestSetPass < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app', :update => 'update')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf
                       )
    @model   = flexmock('model', 
                        :pointer => 'pointer',
                        :is_a? => true
                       )
    flexmock(@model, :model => @model)
    @state   = ODDB::State::StubSetPass.new(@session, @model)
    resolve_state = flexmock('resolve_state', :new => 'new')
    flexmock(@state, 
             :allowed?   => true,
             :error?     => nil,
             :unique_email  => 'unique_email',
             :resolve_state => resolve_state
            )
  end
  def test_update
    assert_equal('new', @state.update)
  end
  def test_update__e_non_matching_set_pass
    flexmock(@state, 
             :user_input   => {:set_pass_1 => 'pass1', :set_pass_2 => 'pass2'},
             :create_error => 'create_error'
            )
    assert_equal('new', @state.update)
  end
  def test_update__runtime_error
    flexmock(@state, :create_error => 'create_error')
    flexmock(@app).should_receive(:update).and_raise(RuntimeError)
    assert_equal(@state, @state.update)
  end
end

  end # State
end # ODDB
