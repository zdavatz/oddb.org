#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/epha_interaction'
require 'stub/odba'

module ODDB
  class TestEphaInteraction <Minitest::Test
    include FlexMock::TestCase
    ATC_CODE_1 = 'N06AB06'
    ATC_CODE_2 = 'G03AA13'
    
    def setup
      @epha_interaction = EphaInteraction.new
      @epha_interaction.atc_code_self = ATC_CODE_1
      @epha_interaction.atc_code_other = ATC_CODE_2
    end
    def test_atc_name
      assert_nil @epha_interaction.atc_name
      @epha_interaction.atc_name = 'A Name'
      assert_equal 'A Name', @epha_interaction.atc_name
    end
    def test_pointer_descr
      @epha_interaction.atc_name = 'name'
      @epha_interaction.info = 'Keine Nebenwirkung'
      assert_equal "#{ATC_CODE_1} name #{ATC_CODE_2} Keine Nebenwirkung", @epha_interaction.pointer_descr
    end
    def test_search_terms
      @epha_interaction.atc_name = 'name'
      @epha_interaction.name_other = 'other'
      @epha_interaction.info = 'Keine Nebenwirkung'
      expected = ["N06AB06", 'name', ATC_CODE_2, "other", "Keine Nebenwirkung"]
      assert_equal expected, @epha_interaction.search_terms
    end
    def test_search_text
      @epha_interaction.atc_name = 'name'
      @epha_interaction.name_other = 'other'
      @epha_interaction.info = 'Keine Nebenwirkung'
      expected = ["N06AB06", 'name', ATC_CODE_2, "other", "Keine Nebenwirkung"].join(' ')
      assert_equal expected, @epha_interaction.search_text
    end
  end
end
