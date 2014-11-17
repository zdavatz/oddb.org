#!/usr/bin/env ruby
# encoding: utf-8
# TestHC_provider -- oddb -- 06.07.2005 -- jlang@ywesee.com, usenguel@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/hc_provider'

module ODDB
	class TestHC_provider <Minitest::Test
    include FlexMock::TestCase
		SampleHC_Type = 'doctor'
    Sample_Key    = '12543'
    Sample_Name   = 'Dr. Max Mustermann'
		def setup
			@hc_provider = HC_provider.new(Sample_Key)
		end
    def test_contact
      assert_nil @hc_provider.contact
			assert_equal(0, @hc_provider.addresses.size)
    end
    def test_pointer_descr
      @hc_provider.name = 'HC_provider'
      @hc_provider.hc_type = SampleHC_Type
      assert_equal "#{Sample_Key} HC_provider #{SampleHC_Type}", @hc_provider.pointer_descr
    end
    def test_search_terms
      @hc_provider.name = Sample_Name
      @hc_provider.hc_type = SampleHC_Type
      @hc_provider.email = 'hc_provider@test.ch'
      @hc_provider.addresses.replace [ flexmock(:search_terms => ['Address', 'Terms'])]
      expected = [ Sample_Key, Sample_Name.sub('.', ''), "hcprovidertestch", 'Address', 'Terms' ]
      assert_equal expected, @hc_provider.search_terms
    end
    def test_search_text
      @hc_provider.name = Sample_Name
      @hc_provider.hc_type = SampleHC_Type
      @hc_provider.email = 'hc_provider@test.ch'
      expected = "#{Sample_Key} #{Sample_Name.sub('.', '')} hcprovidertestch"
      assert_equal expected, @hc_provider.search_text
    end
	end
end
