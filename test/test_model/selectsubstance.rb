#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestSubstance	-- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com 

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/selectsubstance'

module ODDB
  class TestSelectSubstance < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @active_agent = flexmock('active_agent', :pointer => 'pointer')
      @substance = ODDB::SelectSubstance.new('user_input', 'selection', @active_agent)
    end
    def test_pointer
      assert_equal('pointer', @substance.pointer)
    end
    def test_structural_ancestors
      flexmock(@active_agent, :structural_ancestors => 'structural_ancestors')
      assert_equal('structural_ancestors', @substance.structural_ancestors('app'))
    end
    def test_assigned
      sequence = flexmock('sequence', :substances => 'substances')
      flexmock(@active_agent, :sequence => sequence)
      assert_equal('substances', @substance.assigned)
    end
    def test_new_substance
      assert_kind_of(ODDB::Persistence::CreateItem, @substance.new_substance)
    end
  end
end # ODDB
