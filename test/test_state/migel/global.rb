#!/usr/bin/env ruby
# ODDB::State::Migel::TestGlobal -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))


require 'test/unit'
require 'flexmock'
require 'view/welcomehead'
require 'state/migel/global'

module ODDB 
  module State
    module Migel

class TestGlobal < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::Migel::Global.new(@session, @model)
  end
  def test_limit_state
    assert_kind_of(ODDB::State::Migel::Limit, @state.limit_state)
  end
end

    end # Migel
  end # State
end # ODDB
