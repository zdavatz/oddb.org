#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Companies::TestGlobal -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/companies/company'

module ODDB 
  module State
    module Companies

class TestGlobal < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::Companies::Global.new(@session, @model)
  end
  def test_limit_state
    assert_kind_of(ODDB::State::Companies::Limit, @state.limit_state)
  end
end
    end # Companies
  end # State
end
