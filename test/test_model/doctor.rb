#!/usr/bin/env ruby
# TestDoctor -- oddb -- 20.09.2004 -- jlang@ywesee.com


$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/doctor'
require 'mock'

module ODDB
	class TestDoctor < Test::Unit::TestCase
		def setup
			@doctor = Doctor.new
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
		def test_create_prax_address
			assert_nil(@doctor.address(:praxis))
			addr = @doctor.create_address(:praxis)
			assert_instance_of(Address, addr)
			assert_equal(addr, @doctor.address(:praxis))
		end
		def test_create_work_address
			assert_nil(@doctor.address(:work))
			addr = @doctor.create_address(:work)
			assert_instance_of(Address, addr)
			assert_equal(addr, @doctor.address(:work))
		end
		def test_create_both_addresses
			assert_nil(@doctor.address(:work))
			assert_nil(@doctor.address(:praxis))
			addr = @doctor.create_address(:work)
			assert_instance_of(Address, addr)
			assert_equal(addr, @doctor.address(:work))
			assert_nil(@doctor.address(:praxis))
			addr2 = @doctor.create_address(:praxis)
			assert_instance_of(Address, addr2)
			assert_equal(addr2, @doctor.address(:praxis))
			assert_not_same(addr, addr2)
		end
		def test_record_match
			@doctor.origin_db = :origin
			@doctor.origin_id = 12345
			assert(@doctor.record_match?(:origin, 12345))
			assert(!@doctor.record_match?(:oorigin, 12345))
			assert(!@doctor.record_match?(:origin, 54321))
			assert(!@doctor.record_match?(:oorigin, 54321))
		end
	end
end
