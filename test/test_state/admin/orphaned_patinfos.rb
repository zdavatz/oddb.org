#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestOrphanedPatinfos -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'state/admin/orphaned_patinfos'


module ODDB
  module State
    module Admin

class TestOrphanedPatinfos <Minitest::Test
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :size => 1)
    @state   = ODDB::State::Admin::OrphanedPatinfos.new(@session, @model)
  end
  def test_init
    assert_nil(@state.init)
  end
  def test_symbol
    assert_equal(:names, @state.symbol)
  end
end
    end # Admin
  end # State
end # ODDB
