#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestLimitationTexts -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/resultfoot'
require 'state/drugs/limitationtexts'

module ODDB
  module State
    module Drugs

class TestLimitationTexts <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::LimitationTexts.new(@session, @model)
  end
  def test_index_name
    assert_equal('sequence_limitation_text', @state.index_name)
  end
  def test_index_lookup
    sequence = flexmock('sequence', :limitation_text => 'limitation_text')
    flexmock(@session, :search_sequences => [sequence])
    assert_equal([sequence], @state.index_lookup('range'))
  end
end

    end # Drugs
  end # State
end # ODDB
