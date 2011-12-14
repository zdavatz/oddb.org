#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestAdmin -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/admin'

module ODDB
  module State
    module Admin

class StubAdmin
  include ODDB::State::Admin::Admin
  def initialize(session, model)
    @model = model
    @session = session
  end
end

class TestAdmin < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @session = flexmock('session')
    @model   = flexmock('model')
    @admin   = ODDB::State::Admin::StubAdmin.new(@session, @model)
  end
  def test_limited
    assert_equal(false, @admin.limited?)
  end
  def test_new_registration
    flexmock(@model, 
             :is_a? => true,
             :name  => 'name'
            )
    assert_kind_of(ODDB::State::Admin::Registration, @admin.new_registration)
  end
  def test_zones
    expected = [:analysis, :doctors, :interactions, :drugs, :migel, :user, :hospitals, :companies]
    assert_equal(expected, @admin.zones)
  end
end

    end # Admin
  end # State
end # ODDB
