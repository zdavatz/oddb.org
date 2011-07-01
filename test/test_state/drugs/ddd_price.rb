#!/usr/bin/env ruby
# ODDB::State::Drugs::TestDDDPrice -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/compare'
require 'state/drugs/ddd_price'

module ODDB
  module State
    module Drugs

class TestDDDPrice < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @model   = flexmock('model')
    pointer  = flexmock('pointer', 
                        :resolve => @model,
                        :is_a? => true
                       )
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => pointer
                       )
    @state   = ODDB::State::Drugs::DDDPrice.new(@session, @model)
  end
  def test_init
    assert_equal(@model, @state.init)
  end
  def test_init__nil
    flexmock(@session, :user_input => nil)
    assert_nil(@state.init)
  end
end

    end # Drugs
  end # State
end # ODDB
