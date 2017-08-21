#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'model/epha_interaction'
require 'stub/odba'

module ODDB
  class TestEphaInteraction <Minitest::Test
    ATC_CODE_1 = 'N06AB06'
    ATC_CODE_2 = 'G03AA13'

    def setup
      @epha_interaction = ODDB::EphaInteractions::EPHA_INFO.new
      @epha_interaction.atc_code_self = ATC_CODE_1
      @epha_interaction.atc_code_other = ATC_CODE_2
    end
    def test_atc_name
      assert_nil @epha_interaction.atc_name
      @epha_interaction.atc_name = 'A Name'
      assert_equal 'A Name', @epha_interaction.atc_name
    end
  end
end
