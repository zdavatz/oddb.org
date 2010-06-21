#!/usr/bin/env ruby
# TestDoctor -- oddb -- 20.09.2004 -- jlang@ywesee.com -- usenguel@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'model/doctor'
require 'flexmock'

module ODDB
  class Doctor
    public :adjust_types
  end
	class TestDoctor < Test::Unit::TestCase
    include FlexMock::TestCase
		def setup
			@doctor = Doctor.new
		end
		def teardown
			ODBA.storage = nil
		end
		def test_init
			pointer = flexmock 'pointer'
			pointer.should_receive(:append).and_return { |oid|
				assert_equal(@doctor.oid, oid)
			}
			@doctor.pointer = pointer
			@doctor.init(nil)
		end
    def test_fullname
      @doctor.firstname = 'FirstName'
      @doctor.name = 'LastName'
      assert_equal 'FirstName LastName', @doctor.fullname
    end
    def test_pointer_descr
      @doctor.firstname = 'FirstName'
      @doctor.name = 'LastName'
      @doctor.title = 'Dr.'
      assert_equal 'Dr. FirstName LastName', @doctor.pointer_descr
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
			addr1 = flexmock "praxis_addresse1"
			addr1.should_receive(:type).and_return { 'at_praxis' }
			addr2 = flexmock "work_addresse2"
			addr2.should_receive(:type).and_return { 'at_work' }
			addr3 = flexmock "work_addresse3"
			addr3.should_receive(:type).and_return { 'at_work' }
			@doctor.addresses = [addr1, addr2, addr3]
			assert_equal(addr1, @doctor.praxis_address)
		end
		def test_praxis_address__nil
			addr2 = flexmock "work_addresse2"
			addr2.should_receive(:type).and_return { 'at_work' }
			addr3 = flexmock "work_addresse3"
			addr3.should_receive(:type).and_return { 'at_work' }
			@doctor.addresses = [addr2, addr3]
			assert_nil(@doctor.praxis_address)
		end
		def test_praxis_address__not_first
			addr1 = flexmock "praxis_addresse1"
			addr1.should_receive(:type).and_return { 'at_praxis' }
			addr2 = flexmock "work_addresse2"
			addr2.should_receive(:type).and_return { 'at_work' }
			addr3 = flexmock "work_addresse3"
			addr3.should_receive(:type).and_return { 'at_work' }
			@doctor.addresses = [addr2, addr1, addr3]
			assert_equal(addr1, @doctor.praxis_address)
		end
		def test_praxis_addresses
			addr1 = flexmock "praxis_addresse1"
			addr1.should_receive(:type).and_return { 'at_praxis' }
			addr2 = flexmock "work_addresse2"
			addr2.should_receive(:type).and_return { 'at_work' }
			addr3 = flexmock "work_addresse3"
			addr3.should_receive(:type).and_return { 'at_praxis' }
			@doctor.addresses = [addr1, addr2, addr3]
			assert_equal([addr1, addr3], @doctor.praxis_addresses)
		end
		def test_work_addresses
			addr1 = flexmock "praxis_addresse1"
			addr1.should_receive(:type).and_return { 'at_praxis' }
			addr2 = flexmock "work_addresse2"
			addr2.should_receive(:type).and_return { 'at_work' }
			addr3 = flexmock "work_addresse3"
			addr3.should_receive(:type).and_return { 'at_work' }
			@doctor.addresses = [addr1, addr2, addr3]
			expected = [addr2, addr3]
			assert_equal(expected, @doctor.work_addresses)
		end
		def test_work_addresses__nil
			addr1 = flexmock "praxis_addresse1"
			addr1.should_receive(:type).and_return { 'at_praxis' }
			@doctor.addresses = [addr1]
			expected = []
			assert_equal(expected, @doctor.work_addresses)
		end
		def test_work_addresses__first
			addr1 = flexmock "work_addresse1"
			addr1.should_receive(:type).and_return { 'at_work' }
			addr2 = flexmock "work_addresse2"
			addr2.should_receive(:type).and_return { 'at_work' }
			addr3 = flexmock "praxis_addresse3"
			addr3.should_receive(:type).and_return { 'at_praxis' }
			@doctor.addresses = [addr1, addr2, addr3]
			expected =	[addr1, addr2]
			assert_equal(expected, @doctor.work_addresses)
		end
		def test_create_address
			assert_equal([], @doctor.addresses)
			addr = @doctor.create_address(0)
			assert_instance_of(Address2, addr)
			assert_equal([addr], @doctor.addresses)
		end
    def test_search_terms
      @doctor.name = 'Last-Name'
      @doctor.firstname = 'First-Name'
      @doctor.email = 'email@test.ch'
      @doctor.specialities = ['Neurologie']
      @doctor.ean13 = '7681123456789'
      addr = flexmock 'address'
      addr.should_receive(:search_terms).and_return ['Street', 'Location']
      @doctor.addresses.push addr
      expected = [ "Last", "LastName", "Last Name", "First", "FirstName",
                   "First Name", "emailtestch", "Neurologie", "7681123456789",
                   "Street", "Location" ]
      assert_equal expected, @doctor.search_terms
    end
    def test_search_text
      @doctor.name = 'Last-Name'
      @doctor.firstname = 'First-Name'
      @doctor.email = 'email@test.ch'
      @doctor.specialities = ['Neurologie']
      @doctor.ean13 = '7681123456789'
      addr = flexmock 'address'
      addr.should_receive(:search_terms).and_return ['Street', 'Location']
      @doctor.addresses.push addr
      expected = "Last LastName Last Name First FirstName First Name emailtestch Neurologie 7681123456789 Street Location"
      assert_equal expected, @doctor.search_text
    end
    def test_adjust_types
      data = {
        :capabilities => "Neurologie\nPsychiatrie",
        :exam         => '1985',
      }
      expected = {
        :capabilities => %w{Neurologie Psychiatrie},
        :exam         => 1985,
      }
      assert_equal expected, @doctor.adjust_types(data)
    end
	end
end
