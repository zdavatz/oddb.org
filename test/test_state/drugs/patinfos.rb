#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestPatinfos -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/resultfoot'
require 'state/drugs/patinfos'

module ODDB
  module State
    module Drugs

class TestPatinfos <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :name_base => 'name_base')
    @state   = ODDB::State::Drugs::Patinfos.new(@session, @model)
  end
  def test_index_name
    assert_equal('sequence_patinfos', @state.index_name)
  end
end

    end # Drugs
  end # State
end # ODDB
