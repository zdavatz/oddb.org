#!/usr/bin/env ruby
# encoding: utf-8
#  -- oddb -- 07.11.2005 -- ffricker@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'model/narcotic'
require 'flexmock'

module ODDB
  class TestNarcotic < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @narcotic = Narcotic.new
    end
    def test_init
      ptr = Persistence::Pointer.new :narcotic
      @narcotic.pointer = ptr
      @narcotic.init
      assert_equal Persistence::Pointer.new([:narcotic, @narcotic.oid]),
                   @narcotic.pointer
      assert_equal ptr, @narcotic.pointer
    end
    def test_add_package
      narc = FlexMock.new
      res = @narcotic.add_package(narc)
      assert_equal([narc], @narcotic.packages)
      assert_equal(narc, res)
      narc2 = FlexMock.new
      res = @narcotic.add_package(narc2)
      assert_equal([narc, narc2], @narcotic.packages)
      assert_equal(narc2, res)
    end
    def test_add_substance
      sub = flexmock :odba_store => true
      @narcotic.add_substance sub
      assert_equal [sub], @narcotic.substances
      @narcotic.add_substance sub
      assert_equal [sub], @narcotic.substances
    end
    def test_casrn
      @narcotic.substances.push flexmock(:casrn => nil), flexmock(:casrn => '123')
      assert_equal '123', @narcotic.casrn
    end
    def test_checkout
      sub1 = flexmock :odba_store => true
      sub1.should_receive(:narcotic=).with(nil).times(1).and_return do
        @narcotic.remove_substance sub1
        assert true
      end
      sub2 = flexmock :odba_store => true
      sub2.should_receive(:narcotic=).with(nil).times(1).and_return do
        @narcotic.remove_substance sub2
        assert true
      end
      @narcotic.substances.push sub1, sub2
      pac1 = flexmock :odba_store => true
      pac1.should_receive(:remove_narcotic).with(@narcotic).times(1).and_return do
        @narcotic.remove_package pac1
        assert true
      end
      pac2 = flexmock :odba_store => true
      pac2.should_receive(:remove_narcotic).with(@narcotic).times(1).and_return do
        @narcotic.remove_package pac2
        assert true
      end
      @narcotic.packages.push pac1, pac2
      @narcotic.checkout
      assert_equal [], @narcotic.substances
      assert_equal [], @narcotic.packages
    end
    def test_create_reservation_text
      txt = @narcotic.create_reservation_text
      assert_instance_of Text::Document, txt
      assert_equal txt, @narcotic.reservation_text
    end
    def test_pointer_descr
      sub1 = flexmock :to_s => 'Some Substance'
      sub2 = flexmock :to_s => 'Another Substance'
      @narcotic.substances.push sub1, sub2
      assert_equal 'Another Substance', @narcotic.pointer_descr
    end
    def test_remove_package
      narc = FlexMock.new
      narc2 = FlexMock.new
      @narcotic.packages.push(narc)
      @narcotic.packages.push(narc2)
      res = @narcotic.remove_package(narc)
      assert_equal([narc2], @narcotic.packages)
      assert_equal(narc, res)
      res = @narcotic.remove_package(narc)
      assert_equal([narc2], @narcotic.packages)
      assert_equal(nil, res)
      res = @narcotic.remove_package(narc2)
      assert_equal([], @narcotic.packages)
      assert_equal(narc2, res)
    end
    def test_remove_substance
      sub = flexmock 'substance'
      @narcotic.substances.push sub
      @narcotic.remove_substance sub
      assert_equal [], @narcotic.substances
      @narcotic.remove_substance sub
      assert_equal [], @narcotic.substances
    end
    def test_swissmedic_codes
      sub1 = flexmock :swissmedic_code => '4321'
      sub2 = flexmock :swissmedic_code => '1234'
      @narcotic.substances.push sub1, sub2
      assert_equal %w{4321 1234}, @narcotic.swissmedic_codes
    end
    def test_to_s
      sub1 = flexmock :to_s => 'Some Substance'
      sub2 = flexmock :to_s => 'Another Substance'
      @narcotic.substances.push sub1, sub2
      assert_equal 'Another Substance', @narcotic.to_s
    end
  end
end
