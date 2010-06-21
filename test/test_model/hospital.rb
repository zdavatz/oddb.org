#!/usr/bin/env ruby
# TestHospital -- oddb -- 06.07.2005 -- jlang@ywesee.com, usenguel@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/hospital'

module ODDB
	class TestHospital < Test::Unit::TestCase
    include FlexMock::TestCase
		def setup
			@hospital = Hospital.new('12543')
		end
    def test_contact
      assert_nil @hospital.contact
      addr = @hospital.addresses.first
      addr.name = 'A Name'
      assert_equal 'A Name', @hospital.contact
    end
    def test_pointer_descr
      @hospital.name = 'Hospital'
      @hospital.business_unit = 'Neurologie'
      assert_equal 'Hospital Neurologie', @hospital.pointer_descr
    end
    def test_search_terms
      @hospital.name = 'A Name'
      @hospital.business_unit = 'Neurologie'
      @hospital.email = 'hospital@test.ch'
      @hospital.addresses.replace [ flexmock(:search_terms => ['Address', 'Terms'])]
      expected = [
        "A Name", "12543", "Neurologie", "hospitaltestch", "Address", "Terms"
      ]
      assert_equal expected, @hospital.search_terms
    end
    def test_search_text
      @hospital.name = 'A Name'
      @hospital.business_unit = 'Neurologie'
      @hospital.email = 'hospital@test.ch'
      @hospital.addresses.replace [ flexmock(:search_terms => ['Address', 'Terms'])]
      expected = "A Name 12543 Neurologie hospitaltestch Address Terms"
      assert_equal expected, @hospital.search_text
    end
	end
end
