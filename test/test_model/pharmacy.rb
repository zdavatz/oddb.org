#!/usr/bin/env ruby
# encoding: utf-8
# TestPharmacy -- oddb -- 06.07.2005 -- jlang@ywesee.com, usenguel@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'model/pharmacy'

module ODDB
	class TestPharmacy <Minitest::Test
		SampleBA_Type =  ODDB::BA_type::BA_public_pharmacy
    Sample_Key    = '12543'
    Sample_Name   = 'Dr. pharm Max Mustermann'
		def setup
			@pharmacy = Pharmacy.new(Sample_Key)
		end
    def test_contact
      assert_nil @pharmacy.contact
			assert_equal(0, @pharmacy.addresses.size)
    end
    def test_pointer_descr
      @pharmacy.name = 'Pharmacy'
      @pharmacy.business_area = SampleBA_Type
      assert_equal "#{Sample_Key} Pharmacy #{SampleBA_Type}", @pharmacy.pointer_descr
    end
    def test_search_terms
      @pharmacy.name = Sample_Name
      @pharmacy.business_area = SampleBA_Type
      @pharmacy.email = 'pharmacy@test.ch'
      @pharmacy.addresses.replace [ flexmock(:search_terms => ['Address', 'Terms'])]
      expected = [ Sample_Key, Sample_Name.sub('.', ''), "pharmacytestch", 'Address', 'Terms' ]
      assert_equal expected, @pharmacy.search_terms
    end
    def test_search_text
      @pharmacy.name = Sample_Name
      @pharmacy.business_area = SampleBA_Type
      @pharmacy.email = 'pharmacy@test.ch'
      expected = "#{Sample_Key} #{Sample_Name.sub('.', '')} pharmacytestch"
      assert_equal expected, @pharmacy.search_text
    end
    def test_collect_ba_type
      ary = Array.new    #=> []
      ary << ODDB::BA_type::BA_hospital
      assert(ODDB::BA_types.collect)
      assert(ODDB::BA_type.collect)
    end
  end
end
