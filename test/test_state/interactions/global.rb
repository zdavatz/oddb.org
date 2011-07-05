#!/usr/bin/env ruby
# ODDB::State::Interactions::TestGlobal -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/search'
require 'state/interactions/global'


module ODDB
  module State
    module Interactions

class TestGlobal < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state     = ODDB::State::Interactions::Global.new(@session, @model)
  end
  def test_limit_state
    assert_kind_of(ODDB::State::Interactions::Limit, @state.limit_state)
  end
end

    end # Interactions
  end # State
end # ODDB

