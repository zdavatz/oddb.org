#!/usr/bin/env ruby
# TestDoctor -- oddb -- 20.09.2004 -- jlang@ywesee.com -- usenguel@ywesee.com


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
			addr1.__next(:type) { :praxis }
			addr2 = TypeMock.new("work_addresse2")
			addr2.__next(:type) { :work }
			addr3 = TypeMock.new("work_addresse3")
			addr3.__next(:type) { :work }
			@doctor.addresses = [addr1, addr2, addr3]
			assert_equal(addr1, @doctor.praxis_address)
		end
		def test_praxis_address__nil
			addr2 = TypeMock.new("work_addresse2")
			addr2.__next(:type) { :work }
			addr3 = TypeMock.new("work_addresse3")
			addr3.__next(:type) { :work }
			@doctor.addresses = [addr2, addr3]
			assert_nil(@doctor.praxis_address)
		end
		def test_praxis_address__not_first
			addr1 = TypeMock.new("praxis_addresse1")
			addr1.__next(:type) { :praxis }
			addr2 = TypeMock.new("work_addresse2")
			addr2.__next(:type) { :work }
			addr3 = TypeMock.new("work_addresse3")
			addr3.__next(:type) { :work }
			@doctor.addresses = [addr2, addr1, addr3]
			assert_equal(addr1, @doctor.praxis_address)
		end
		def test_work_addresses
			addr1 = TypeMock.new("praxis_addresse1")
			addr1.__next(:type) { :praxis }
			addr2 = TypeMock.new("work_addresse2")
			addr2.__next(:type) { :work }
			addr3 = TypeMock.new("work_addresse3")
			addr3.__next(:type) { :work }
			@doctor.addresses = [addr1, addr2, addr3]
			expected = [addr2, addr3]
			assert_equal(expected, @doctor.work_addresses)
		end
		def test_work_addresses__nil
			addr1 = TypeMock.new("praxis_addresse1")
			addr1.__next(:type) { :praxis }
			@doctor.addresses = [addr1]
			expected = []
			assert_equal(expected, @doctor.work_addresses)
		end
		def test_work_addresses__first
			addr1 = TypeMock.new("work_addresse1")
			addr1.__next(:type) { :work }
			addr2 = TypeMock.new("work_addresse2")
			addr2.__next(:type) { :work }
			addr3 = TypeMock.new("praxis_addresse3")
			addr3.__next(:type) { :praxis }
			@doctor.addresses = [addr1, addr2, addr3]
			expected =	[addr1, addr2]
			assert_equal(expected, @doctor.work_addresses)
		end
	end
end
