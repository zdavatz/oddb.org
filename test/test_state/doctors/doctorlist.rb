#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Doctors::TestDoctorList -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/welcomehead'
require 'state/doctors/doctorlist'

module ODDB
  module State
    module Doctors

class TestDoctorList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :size => 1)
    @list    = ODDB::State::Doctors::DoctorList.new(@session, @model)
  end
  def test_init
    assert_nil(@list.init)
  end
  def test_paged
    assert_equal(false, @list.paged?)
  end
  def test_symbol
    assert_equal(:name, @list.symbol)
  end
end

class TestDoctorResult < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @list    = ODDB::State::Doctors::DoctorResult.new(@session, [@model])
  end
  def test_init
    assert_nil(@list.init)
  end
  def test_init__model_empty
    list = ODDB::State::Doctors::DoctorResult.new(@session, [])
    assert_equal(ODDB::View::Doctors::EmptyResult, list.init)
  end

end

    end # Doctors
  end # State
end # ODDB
