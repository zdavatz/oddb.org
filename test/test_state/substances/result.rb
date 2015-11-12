#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Substances::TestResult -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/substances/result'

module ODDB
  module State
    module Substances

class TestResult <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model1  = flexmock('model1', :name => 'name')
    @model2  = flexmock('model2', :name => 'name')
    @state   = ODDB::State::Substances::Result.new(@session, [@model1, @model2])
  end
  def test_init
    assert_equal([@model1, @model2], @state.init)
  end
  def test_init__empty
    state = ODDB::State::Substances::Result.new(@session, [])
    assert_equal(ODDB::View::Substances::EmptyResult, state.init)
  end
end

    end # Substances
  end # State
end # ODDB
