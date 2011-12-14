#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Hospitals::TestGlobal -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

#require 'state/global'

require 'test/unit'
require 'flexmock'
require 'view/welcomehead'
require 'state/hospitals/global'

module ODDB
  module State
    module Hospitals

class TestGlobal < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::Hospitals::Global.new(@session, @model)
  end
  def test_limit_state
    assert_kind_of(ODDB::State::Hospitals::Limit, @state.limit_state)
  end
end


    end # Hospitals
  end # State
end # ODDB

