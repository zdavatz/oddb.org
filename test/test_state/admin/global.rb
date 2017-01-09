#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestGlobal -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'state/global'
require 'state/admin/global'

module ODDB
  module State
    module Admin

class TestGlobal <Minitest::Test
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :allowed? => nil
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::Global.new(@session, @model)
  end
  def test_zone_navigation
    assert_equal([], @state.zone_navigation)
  end
end

    end # Admin
  end # State
end # ODDB
