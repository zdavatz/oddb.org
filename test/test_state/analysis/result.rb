#!/usr/bin/env ruby
# ODDB::State::Analysis::TestResult -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'
require 'state/analysis/result'

module ODDB
  module State
    module Analysis

class TestResult < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :empty? => true)
    @state   = ODDB::State::Analysis::Result.new(@session, @model)
  end
  def test_init
    assert_equal(ODDB::View::Analysis::EmptyResult, @state.init)
  end
end

    end # Admin
  end # State
end # ODDB
