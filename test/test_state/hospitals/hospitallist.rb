#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Hospitals::TestHospitalList -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/companies/companylist'
require 'state/hospitals/hospitallist'

module ODDB
  module State
    module Hospitals

class TestHospitalList <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :size => 1)
    @state   = ODDB::State::Hospitals::HospitalList.new(@session, @model)
  end
  def test_init
    assert_nil(@state.init)
  end
  def test_symbol
    assert_equal(:name, @state.symbol)
  end
end

class TestHospitalResult <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::Hospitals::HospitalResult.new(@session, [@model])
  end
  def test_init
    assert_nil(@state.init)
  end
  def test_init__empty
    state = ODDB::State::Hospitals::HospitalResult.new(@session, [])
    assert_equal(ODDB::View::Hospitals::EmptyResult, state.init)
  end

end

    end # Hospitals
  end # State
end # ODDB

