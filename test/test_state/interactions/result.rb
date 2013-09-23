#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Interactions::TestResult -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Interactions::TestResult -- oddb.org -- 01.06.2004 -- mhuggler@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/search'
require 'view/resulttemplate'
require 'state/interactions/result'


module ODDB
  module State
    module Interactions

class TestResult <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model1  = flexmock('model1', :name => 'name1')
    @model2  = flexmock('model2', :name => 'name2')
    @state   = ODDB::State::Interactions::Result.new(@session, [@model1, @model2])
  end
  def test_init
    assert_equal([@model1, @model2], @state.init)
  end
  def test_init__empty
    state = ODDB::State::Interactions::Result.new(@session, [])
    assert_equal(ODDB::View::Interactions::EmptyResult, state.init)
  end
end

    end # Interactions
  end # State
end # ODDB

