#!/usr/bin/env ruby
# ODDB::State::Ajax::TestDDDPrice -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'sbsm/state'
require 'state/ajax/ddd_price'

module ODDB
  module State
    module Ajax

class TestDDDPrice < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @model   = flexmock('model')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    pointer  = flexmock('pointer', 
                        :resolve => @model,
                        :is_a? => true
                       )
    @session = flexmock('session',
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => pointer
                       )
    @state   = ODDB::State::Ajax::DDDPrice.new(@session, @model)
  end
  def test_init
    assert_equal(@model, @state.init)
  end
  def test_init__nil
    flexmock(@session, :user_input => nil)
    assert_nil(@state.init)
  end
end

    end # Ajax
  end # State
end # ODDB
