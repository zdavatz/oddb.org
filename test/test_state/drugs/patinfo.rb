#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestPatinfo -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/drugs/patinfo'

module ODDB
  module State
    module Drugs

class TestPatinfo <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :name_base => 'name_base')
    @state   = ODDB::State::Drugs::Patinfo.new(@session, @model)
  end
  def test_init
    assert_equal('lookup', @state.init)
  end
end

    end # Drugs
  end # State
end # ODDB
