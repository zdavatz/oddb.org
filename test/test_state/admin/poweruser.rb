#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestPowerUser -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))


gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/poweruser'

module ODDB
  module State
    module Admin

class StubSuper
  def limited?
    'limited'
  end
end
class StubPowerUser < StubSuper
  include ODDB::State::Admin::PowerUser
  def initialize(session, model)
    @model = model
    @session = session
  end
end

class TestPowerUser <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :allowed? => nil
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::StubPowerUser.new(@session, @model)
  end
  def test_limited
    assert(@state.limited?)
  end
  def test_limit_state
    user = flexmock('user', :allowed? => nil, :valid? => true)
    flexmock(@session, :user => user)
    assert_kind_of(ODDB::State::User::InvalidUser, @state.limit_state)
  end
end

    end # Admin
  end # State
end # ODDB
