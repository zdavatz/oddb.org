#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Ajax::TestGlobal -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'sbsm/state'
require 'state/ajax/global'

module ODDB
  module State
    module Ajax

class TestGlobal <Minitest::Test
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::Ajax::Global.new(@session, @model)
  end
  def test_limited
    assert_equal(false, @state.limited?)
  end
end

    end # Ajax
  end # State
end # ODDB
