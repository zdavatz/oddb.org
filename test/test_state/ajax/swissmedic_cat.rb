#!/usr/bin/env ruby
# ODDB::State::Ajax::TestSwissmedicCat -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'sbsm/state'
require 'util/persistence'
require 'state/ajax/swissmedic_cat'

module ODDB
  module State
    module Ajax

class TestSwissmedicCat < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @model   = flexmock('model')
    @pointer = flexmock('pointer', 
                        :is_a? => true,
                        :resolve => @model
                       )
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => @pointer
                       )
    @state   = ODDB::State::Ajax::SwissmedicCat.new(@session, @model)
  end
  def test_init
    assert_equal(@model, @state.init)
  end
  def test_init__nil
    flexmock(@pointer, :is_a? => false)
    assert_nil(@state.init)
  end
end

    end # Ajax
  end # State
end # ODDB
