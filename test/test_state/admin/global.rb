#!/usr/bin/env ruby
# ODDB::State::Admin::TestGlobal -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/global'
require 'state/admin/global'

module ODDB
  module State
    module Admin

class TestGlobal < Test::Unit::TestCase
  include FlexMock::TestCase
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
