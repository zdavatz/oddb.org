#!/usr/bin/env ruby
# encoding: utf-8
# enconding: utf-8
# ODDB::State::Substances::TestSubstances -- oddb.org -- 17.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/search'
require 'state/substances/substances'

module ODDB
  module State
    module Sustances

class TestSubstances < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :size => 1)
    @state   = ODDB::State::Substances::Substances.new(@session, [@model])
  end
  def test_init
    assert_nil(@state.init)
  end
  def test_default_interval
    assert_equal('|unknown', @state.default_interval)
  end
end

    end # Substances
  end # State
end # ODDB
