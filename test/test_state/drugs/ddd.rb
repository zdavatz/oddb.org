#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestDDD -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/drugs/ddd'

module ODDB
  module State
    module Drugs

class TestDDD <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    pointer  = flexmock('pointer')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => pointer
                       )
    @model   = flexmock('model')
    flexmock(pointer, :resolve => @model)
    @state   = ODDB::State::Drugs::DDD.new(@session, @model)
  end
  def test_init
    assert_equal(@model, @state.init)
  end
end

    end # Drugs
  end # State
end # ODDB
