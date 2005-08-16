#!/usr/bin/env ruby
# TestDoctor -- oddb -- 20.09.2004 -- jlang@ywesee.com -- usenguel@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/doctor'
require 'mock'
require 'odba'

module ODDB
	class TestDoctor < Test::Unit::TestCase
		class TypeMock < Mock
			def type
				true
			end
		end
		def setup
			ODBA.storage = Mock.new
			ODBA.storage.__next(:next_id){
				1
			}
			@doctor = Doctor.new
		end
		def teardown
			ODBA.storage = nil
		end
		def test_init
			pointer = Mock.new('Pointer')
			pointer.__next(:append) { |oid|
				assert_equal(@doctor.oid, oid)
			}
			@doctor.pointer = pointer
			@doctor.init(nil)
			pointer.__verify
		end
		def test_record_match
			@doctor.origin_db = :origin
			@doctor.origin_id = 12345
			assert(@doctor.record_match?(:origin, 12345))
			assert(!@doctor.record_match?(:oorigin, 12345))
			assert(!@doctor.record_match?(:origin, 54321))
			assert(!@doctor.record_match?(:oorigin, 54321))
		end
		def test_praxis_address
			addr1 = TypeMock.new("praxis_addresse1")
			addr1.__next(:type) { 'at_praxis' }
			addr2 = TypeMock.new("work_addresse2")
			addr2.__next(:type) { 'at_work' }
			addr3 = TypeMock.new("work_addresse3")
			addr3.__next(:type) { 'at_work' }
			@doctor.addresses = [addr1, addr2, addr3]
			assert_equal(addr1, @doctor.praxis_address)
		end
		def test_praxis_address__nil
			addr2 = TypeMock.new("work_addresse2")
			addr2.__next(:type) { 'at_work' }
			addr3 = TypeMock.new("work_addresse3")
			addr3.__next(:type) { 'at_work' }
			@doctor.addresses = [addr2, addr3]
			assert_nil(@doctor.praxis_address)
		end
		def test_praxis_address__not_first
			addr1 = TypeMock.new("praxis_addresse1")
			addr1.__next(:type) { 'at_praxis' }
			addr2 = TypeMock.new("work_addresse2")
			addr2.__next(:type) { 'at_work' }
			addr3 = TypeMock.new("work_addresse3")
			addr3.__next(:type) { 'at_work' }
			@doctor.addresses = [addr2, addr1, addr3]
			assert_equal(addr1, @doctor.praxis_address)
		end
		def test_work_addresses
			addr1 = TypeMock.new("praxis_addresse1")
			addr1.__next(:type) { 'at_praxis' }
			addr2 = TypeMock.new("work_addresse2")
			addr2.__next(:type) { 'at_work' }
			addr3 = TypeMock.new("work_addresse3")
			addr3.__next(:type) { 'at_work' }
			@doctor.addresses = [addr1, addr2, addr3]
			expected = [addr2, addr3]
			assert_equal(expected, @doctor.work_addresses)
		end
		def test_work_addresses__nil
			addr1 = TypeMock.new("praxis_addresse1")
			addr1.__next(:type) { 'at_praxis' }
			@doctor.addresses = [addr1]
			expected = []
			assert_equal(expected, @doctor.work_addresses)
		end
		def test_work_addresses__first
			addr1 = TypeMock.new("work_addresse1")
			addr1.__next(:type) { 'at_work' }
			addr2 = TypeMock.new("work_addresse2")
			addr2.__next(:type) { 'at_work' }
			addr3 = TypeMock.new("praxis_addresse3")
			addr3.__next(:type) { 'at_praxis' }
			@doctor.addresses = [addr1, addr2, addr3]
			expected =	[addr1, addr2]
			assert_equal(expected, @doctor.work_addresses)
		end
		def test_refactor_addresse__1
			@doctor.pointer = [:doctor, 1]
			address = Address.new
			address.lines = [ "Monsieur le Docteur", 
				"Michel Voirol", "Cabinet M.", 
				"18, rue des Remparts", 
				"1400 Yverdon-les-Bains", ""]
			address.plz = "1400"
			address.city = "Yverdon-les-Bains"
			address.type = :work
			address.fon = ['fon1', 'fon2']
			address.fax = ['fax1', 'fax2']

			addr = @doctor.refactor_address(address, 2)
			assert_instance_of(Address2, addr)
			
			assert_equal('Monsieur le Docteur', addr.title)
			assert_equal('Michel Voirol' , addr.name)
			assert_equal('18, rue des Remparts' , addr.address)
			assert_equal('1400 Yverdon-les-Bains', addr.location)
			assert_equal(['Cabinet M.'], addr.additional_lines)
			assert_equal([:doctor, 1, :address, 2],
				addr.pointer)
			assert_equal("at_work", addr.type)
			assert_equal(['fon1', 'fon2'], addr.fon)
			assert_equal(['fax1', 'fax2'], addr.fax)
		end
		def test_refactor_addresse__2
			@doctor.pointer = [:doctor, 1]
			address = Address.new
			address.lines = [ "Monsieur le Docteur", 
				"Michel Voirol", "Cabinet M.", "AD",
				"18, rue des Remparts", 
				"1400 Yverdon-les-Bains", ""]
			address.plz = "1400"
			address.city = "Yverdon-les-Bains"
			address.type = :praxis

			addr = @doctor.refactor_address(address, 3)
			assert_instance_of(Address2, addr)
			
			assert_equal('Michel Voirol' , addr.name)
			assert_equal('18, rue des Remparts' , addr.address)
			assert_equal('1400 Yverdon-les-Bains', addr.location)
			assert_equal(['Cabinet M.', 'AD'], addr.additional_lines)
			assert_equal([:doctor, 1, :address, 3],
				addr.pointer)
			assert_equal("at_praxis", addr.type)
		end
		def test_refactor_addresse__3
			@doctor.pointer = [:doctor, 1]
			address = Address.new
			address.lines = [
				"Michel Voirol",
				"18, rue des Remparts", 
				"1400 Yverdon-les-Bains", ""]
			address.plz = "1400"
			address.city = "Yverdon-les-Bains"

			addr = @doctor.refactor_address(address, 0)
			assert_instance_of(Address2, addr)
			
			assert_nil(addr.title)
			assert_equal('Michel Voirol' , addr.name)
			assert_equal('18, rue des Remparts' , addr.address)
			assert_equal('1400 Yverdon-les-Bains', addr.location)
			assert_equal([:doctor, 1, :address, 0],
				addr.pointer)
			assert_equal([], addr.additional_lines)
		end
	end
end
