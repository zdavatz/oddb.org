#!/usr/bin/env ruby
# encoding: utf-8
# TestIndication -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/indication'

module ODDB
  class Indication
    attr_reader :registrations
  end
  class TestIndication <Minitest::Test
    include FlexMock::TestCase
    class StubRegistration
    end
    def setup
      @indication = Indication.new
    end
    def test_add_remove_registration
      assert_equal([], @indication.registrations)
      reg1 = StubRegistration.new
      reg2 = StubRegistration.new
      reg3 = StubRegistration.new
      @indication.add_registration(reg1)
      assert_equal([reg1], @indication.registrations)
      @indication.add_registration(reg2)
      @indication.add_registration(reg3)
      assert_equal([reg1, reg2, reg3], @indication.registrations)
      @indication.remove_registration(reg2)
      assert_equal([reg1, reg3], @indication.registrations)
      @indication.remove_registration(reg1)
      assert_equal([reg3], @indication.registrations)
      @indication.remove_registration(reg3)
      assert_equal([], @indication.registrations)
    end
    def test_atc_classes
      reg1 = flexmock :atc_classes => ['atc1', 'atc2']
      reg2 = flexmock :atc_classes => [nil, 'atc3']
      seq1 = flexmock :atc_class => 'atc2'
      seq2 = flexmock :atc_class => nil
      @indication.registrations.push reg1, reg2
      @indication.sequences.push seq1, seq2
      assert_equal %w{atc1 atc2 atc3}, @indication.atc_classes
    end
    def test_empty__registration
      assert_equal(true, @indication.empty?)
      reg1 = StubRegistration.new
      @indication.add_registration(reg1)
      assert_equal(false, @indication.empty?)
    end
    def test_empty__sequence
      assert_equal(true, @indication.empty?)
      reg1 = StubRegistration.new
      @indication.add_sequence(reg1)
      assert_equal(false, @indication.empty?)
    end
    def test_registration_count
      assert_equal(0, @indication.registration_count)
      reg1 = StubRegistration.new
      @indication.add_registration(reg1)
      assert_equal(1, @indication.registration_count)
    end
    def test_search_text
      @indication.update_values 'de' => 'Deutsch', 'fr' => 'Français'
      assert_equal 'Deutsch', @indication.search_text(:de)
      assert_equal 'Francais', @indication.search_text(:fr)
      assert_equal 'Deutsch Francais', @indication.search_text
      assert_equal 'Deutsch', @indication.to_s
    end
    def test_merge
      reg1 = flexmock 'reg1'
      reg2 = flexmock 'reg2'
      seq1 = flexmock 'seq1'
      seq2 = flexmock 'seq2'
      reg1.should_receive(:indication=).with(@indication).times(1).and_return do
        assert true
      end
      reg2.should_receive(:indication=).with(@indication).times(1).and_return do
        assert true
      end
      seq1.should_receive(:indication=).with(@indication).times(1).and_return do
        assert true
      end
      seq2.should_receive(:indication=).with(@indication).times(1).and_return do
        assert true
      end
      other = Indication.new
      other.update_values 'de' => 'Deutsch', 'fr' => 'Français',
                          :synonyms => ['Synonyms']
      other.registrations.push reg1, reg2
      other.sequences.push seq1, seq2
      @indication.merge other
      assert_equal ['Synonyms', 'Deutsch', 'Français'], @indication.synonyms
    end
  end
end
