#!/usr/bin/env ruby
# ODDB::State::TestLimit -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/limit'

module ODDB 
  module State

class StubLimit
  include ODDB::State::Limit
  def initialize(session, model)
    @model = model
    @session = session
  end
end
class TestLimit < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :valid_input => 'valid_input'
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::StubLimit.new(@session, @model)
  end
  def test_init
    assert_equal('valid_input', @state.init)
  end
  def test_price
    assert_in_delta(5.0, @state.price(1), 0.001)
  end
end

  end # State
end # ODDB
