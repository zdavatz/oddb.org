#!/usr/bin/env ruby
# TestHospital -- oddb -- 06.07.2005 -- jlang@ywesee.com, usenguel@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/hospital'

module ODDB
	class TestHospital < Test::Unit::TestCase
		def setup
			@hospital = Hospital.new('12543')
		end
		def test_refactor_addresses
			@hospital.pointer = [:hospital, 1]
			@hospital.business_unit = 'Apotheke' 
			@hospital.address = 'Meissenbergstrasse 17'
			@hospital.plz = '6300'
			@hospital.location = 'Zug'
			@hospital.phone = 'fon'
			@hospital.fax = 'fax'
			result = @hospital.refactor_addresses
			assert_instance_of(Array, result)
			assert_equal(1, result.size)
			addr = result.first
			assert_instance_of(Address2, addr)
			
			assert_equal(['Apotheke'], addr.additional_lines)
			assert_equal('Meissenbergstrasse 17' , addr.address)
			assert_equal('6300 Zug', addr.location)
			assert_equal(['fon'], addr.fon)
			assert_equal(['fax'], addr.fax)
			assert_equal([:hospital, 1, :address, 0], 
				addr.pointer)
			assert_equal(result, @hospital.addresses)
		end
	end
end
