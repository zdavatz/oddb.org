#!/usr/bin/env ruby
# encoding: utf-8
# TestGroup -- oddb -- 13.09.2005 -- spfenninger@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'flexmock'
require 'model/migel/group'

module ODDB
  module Migel
    class TestGroup < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @group = ODDB::Migel::Group.new('02')
      end
      def test_checkout
        subgroup = flexmock 'subgroup'
        @group.subgroups.store 'subgroup', subgroup
        assert_raises RuntimeError do
          @group.checkout
        end
        @group.subgroups.clear
        assert_nothing_raised do
          @group.checkout
        end
      end
      def test_create_limitation_text
        assert_nil @group.limitation_text
        res = @group.create_limitation_text
        assert_instance_of LimitationText, res
        assert_equal res, @group.limitation_text
      end
      def test_create_subgroup
        subgroup = @group.create_subgroup('02')
        assert_instance_of(Subgroup, subgroup)
        assert_equal({'02' => subgroup}, @group.subgroups)
        assert_equal('02', @group.code)
        assert_equal(@group, subgroup.group)
        assert_equal(subgroup, @group.subgroup('02'))
      end
      def test_delete_limitation_text
        lt = flexmock :odba_delete => true
        @group.instance_variable_set '@limitation_text', lt
        @group.delete_limitation_text
        assert_nil @group.limitation_text
      end
      def test_delete_subgroup
        @group.subgroups.store '02', 'subgroup'
        res = @group.delete_subgroup '02'
        assert_equal 'subgroup', res
        assert_equal({}, @group.subgroups)
      end
      def test_migel_code
        assert_equal '02', @group.migel_code
      end
    end
  end
end
