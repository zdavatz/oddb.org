#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/medical_interaction'
require 'stub/odba'

module ODDB
  class TestMedicalProduct <Minitest::Test
    include FlexMock::TestCase
    ATC_CODE_1 = 'N06AB06'
    ATC_CODE_2 = 'G03AA13'
    
    def setup
      @medical_interaction = MedicalProduct.new
      @medical_interaction.atc_code_self = ATC_CODE_1
      @medical_interaction.atc_code_other = ATC_CODE_2
    end
    def test_atc_name
      assert_nil @medical_interaction.atc_name
      @medical_interaction.atc_name = 'A Name'
      assert_equal 'A Name', @medical_interaction.atc_name
    end
    def test_pointer_descr
      @medical_interaction.atc_name = 'name'
      @medical_interaction.info = 'Keine Nebenwirkung'
      assert_equal "#{ATC_CODE_1} name #{ATC_CODE_2} Keine Nebenwirkung", @medical_interaction.pointer_descr
    end
    def test_search_terms
      @medical_interaction.atc_name = 'name'
      @medical_interaction.name_other = 'other'
      @medical_interaction.info = 'Keine Nebenwirkung'
      expected = ["N06AB06", 'name', ATC_CODE_2, "other", "Keine Nebenwirkung"]
      assert_equal expected, @medical_interaction.search_terms
    end
    def test_search_text
      @medical_interaction.atc_name = 'name'
      @medical_interaction.name_other = 'other'
      @medical_interaction.info = 'Keine Nebenwirkung'
      expected = ["N06AB06", 'name', ATC_CODE_2, "other", "Keine Nebenwirkung"].join(' ')
      assert_equal expected, @medical_interaction.search_text
    end
  end
end
