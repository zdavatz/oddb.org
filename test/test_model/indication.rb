#!/usr/bin/env ruby
# TestIndication -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'model/indication'

module ODDB
	class Indication
		attr_reader :registrations
	end
end

class TestIndication < Test::Unit::TestCase
	class StubRegistration
	end

	def setup
		@indication = ODDB::Indication.new
	end
	def test_add_remove_registration
		assert_equal([], @indication.registrations)
		reg1 = StubRegistration.new
		reg2 = StubRegistration.new
		reg3 = StubRegistration.new
		@indication.add_registration(reg1)
		assert_equal([reg1], @indication.registrations)
		@indication.add_registration(reg2)
		@indication.add_registration(reg3)
		assert_equal([reg1, reg2, reg3], @indication.registrations)
		@indication.remove_registration(reg2)
		assert_equal([reg1, reg3], @indication.registrations)
		@indication.remove_registration(reg1)
		assert_equal([reg3], @indication.registrations)
		@indication.remove_registration(reg3)
		assert_equal([], @indication.registrations)
	end
	def test_registration_count
		assert_equal(0, @indication.registration_count)
		reg1 = StubRegistration.new
		@indication.add_registration(reg1)
		assert_equal(1, @indication.registration_count)
	end
	def test_empty__registration
		assert_equal(true, @indication.empty?)
		reg1 = StubRegistration.new
		@indication.add_registration(reg1)
		assert_equal(false, @indication.empty?)
	end
	def test_empty__sequence
		assert_equal(true, @indication.empty?)
		reg1 = StubRegistration.new
		@indication.add_sequence(reg1)
		assert_equal(false, @indication.empty?)
	end
end
