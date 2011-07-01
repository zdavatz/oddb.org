#!/usr/bin/env ruby
# ODDB::State::Admin::TestOrphanedPatinfos -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/orphaned_patinfos'


module ODDB
  module State
    module Admin

class TestOrphanedPatinfos < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :size => 1)
    @state   = ODDB::State::Admin::OrphanedPatinfos.new(@session, @model)
  end
  def test_init
    assert_equal(nil, @state.init)
  end
  def test_symbol
    assert_equal(:names, @state.symbol)
  end
end
    end # Admin
  end # State
end # ODDB
