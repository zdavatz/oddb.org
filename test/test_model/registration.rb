#!/usr/bin/env ruby
# TestRegistration -- oddb -- 24.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/persistence'
require 'model/registration'
require 'model/incompleteregistration'
require 'mock'

module ODDB
	class RegistrationCommon
		attr_accessor :sequences
		attr_reader :replaced, :fachinfo_oid
		public :adjust_types
	end
	module Persistence
		class Pointer
			attr_reader :directions
		end
	end
end
class StubRegistrationSequence
	attr_reader :seqnr, :accepted, :block_result
	attr_accessor :registration, :atc_class, :name, :substance_names
	def initialize(key)
		@seqnr = key
	end
	def accepted!(*args)
		@accepted = true
	end
	def acceptable?
		@atc_class && @name
	end
	def each_package (&block)
		@block_result = block.call(@seqnr)
	end
	def package_count
		4
	end
end
class StubRegistrationCompany
	attr_reader :name, :registrations
	def initialize(name)
		@name = name
		@registrations = []
	end
	def oid
		1
	end
	def add_registration(registration)
		@registrations.push(registration)
	end
	def remove_registration(registration)
		@registrations.delete_if { |reg| reg == registration }
	end
end
class StubRegistrationApp
	attr_reader :pointer, :values, :delete_pointer
	def initialize
		@companies = {}
	end
	def company(name)
		@companies[name] ||= StubRegistrationCompany.new(name)
	end
	def update(pointer, values)
		@pointer, @values = pointer, values
	end
	def delete(pointer)
		@delete_pointer = pointer
	end
end
class StubRegistrationIndication
	attr_reader :added, :removed
	attr_accessor :oid
	def add_registration(reg)
		@added = reg
	end
	def remove_registration(reg)
		@removed = reg
	end
end
class StubRegistrationPatinfo
	attr_reader :added, :removed
	def add_registration(reg)
		@added = reg
	end
	def remove_registration(reg)
		@removed = reg
	end
end

class TestRegistration < Test::Unit::TestCase
	def setup
		@registration = ODDB::Registration.new('12345')
	end
	def test_iksnr
		assert_respond_to(@registration, :iksnr)
		assert_equal('12345', @registration.iksnr)
	end
	def test_update_values
		assert_nil(@registration.registration_date)
		values = {
			:registration_date	=>	'12.04.2002',
			:company						=>	'Bayer (Schweiz) AG',
			:generic_type				=>	:generic,
		}
		app = StubRegistrationApp.new
		@registration.update_values(@registration.diff(values, app))
		assert_equal(Date.new(2002,4,12), @registration.registration_date)
		company = @registration.company
		assert_equal(app.company('Bayer (Schweiz) AG'), company)
		assert_equal(:generic, @registration.generic_type)
		assert_equal(@registration, company.registrations.first)
		values[:company] = 'Jansen Cilag AG'
		@registration.update_values(@registration.diff(values, app))
		assert_equal([], company.registrations)
	end
	def test_diff
		values = {
			:registration_date	=>	'12.04.2002',
			:generic_type			=>	:generic,
		}
		expected = {
			:registration_date	=>	Date.new(2002,4,12),
			:generic_type			=>	:generic,
		}
		diff = @registration.diff(values)
		assert_equal(expected, diff)
		@registration.update_values(diff)
		assert_equal({}, @registration.diff(values))
	end
	def test_create_sequence
		@registration.sequences = {}
		seq = @registration.create_sequence('01')
		assert_equal(seq, @registration.sequences['01'])
		assert_equal(@registration, seq.registration)
		seq1 = @registration.create_sequence(2)
		assert_equal(seq1, @registration.sequences['02'])
	end
	def test_generic_type
		company = Mock.new("company")
		@registration.company = company 
		company.__next(:generic_type) { "complementary" }	
		assert_equal("complementary", @registration.generic_type)
		@registration.generic_type = "generic"
		assert_equal("generic", @registration.generic_type)
	end
	def test_sequence
		seq = StubRegistrationSequence.new('01')
		@registration.sequences = {'01'=>seq }
		assert_equal(seq, @registration.sequence('01'))
	end
	def test_adjust_types1
		values = {
			:registration_date	=>	nil,
			:revision_date			=>	nil,
			:expiration_date		=>	nil,
			:inactive_date			=>	nil,
			:market_date				=>	nil,
		}
		expected = {
			:registration_date	=>	nil,
			:revision_date			=>	nil,
			:expiration_date		=>	nil,
			:inactive_date			=>	nil,
			:market_date				=>	nil,
		}
		assert_equal(expected, @registration.adjust_types(values))
	end
	def test_adjust_types2
		@registration.registration_date = Date.new(2002,1,1)
		values = {
			:registration_date	=>	'2002-02-02',
			:revision_date			=>	Date.new(2003,1,30),
			:expiration_date		=>	'2004-12-20',
			:inactive_date			=>	'2004-12-20',
		}
		expected = {
			:registration_date	=>	Date.new(2002,2,2),
			:revision_date			=>	Date.new(2003,1,30),
			:expiration_date		=>	Date.new(2004,12,20),
			:inactive_date			=>	Date.new(2004,12,20),
		}
		assert_equal(expected, @registration.adjust_types(values))
	end
	def test_atcless_sequences
		seq1 = StubRegistrationSequence.new('01')
		seq2 = StubRegistrationSequence.new('02')
		seq2.atc_class = 'foo'
		@registration.sequences = {
			'01'	=>	seq1,
			'02'	=>	seq2,
		}
		expected = [ seq1 ]
		assert_equal(expected, @registration.atcless_sequences)
	end
	def test_active
		assert_equal(true, @registration.active?)
		@registration.inactive_date = (Date.today >> 1)
		assert_equal(true, @registration.active?)
		@registration.inactive_date = Date.today 
		assert_equal(true, @registration.active?)
		@registration.inactive_date = (Date.today << 1)
		assert_equal(false, @registration.active?)
	end
	def test_indication_writer
		indication1 = StubRegistrationIndication.new
		indication2 = StubRegistrationIndication.new
		@registration.indication = indication1
		assert_equal(indication1, @registration.indication)
		assert_equal(@registration, indication1.added)
		assert_nil(indication1.removed)
		@registration.indication = indication2
		assert_equal(@registration, indication1.removed)
		assert_equal(@registration, indication2.added)
		assert_nil(indication2.removed)
		@registration.indication = nil
		assert_equal(@registration, indication2.removed)
	end
	def test_each_package
		seq1 = StubRegistrationSequence.new(1)
		seq2 = StubRegistrationSequence.new(2)
		seq3 = StubRegistrationSequence.new(3)
		@registration.sequences = {
			1 => seq1,
			2 => seq2,
			3 => seq3,
		}
		@registration.each_package { |seq|
			seq*seq
		}
		assert_equal(1, seq1.block_result)
		assert_equal(4, seq2.block_result)
		assert_equal(9, seq3.block_result)
	end
	def test_name_base
		@registration.sequences = {}
		assert_nothing_raised { @registration.name_base }
	end
	def test_package_count
		@registration.sequences = {
			'seq1'	=>	StubRegistrationSequence.new(1),
			'seq2'	=>	StubRegistrationSequence.new(2),
			'seq3'	=>	StubRegistrationSequence.new(3),
		}
		result = @registration.package_count
		assert_equal(12, result)
	end
	def test_fachinfo_writer
		fachinfo1 = StubRegistrationIndication.new
		fachinfo1.oid = 2
		fachinfo2 = StubRegistrationIndication.new
		fachinfo2.oid = 3
		@registration.fachinfo = fachinfo1
		assert_equal(@registration, fachinfo1.added)
		assert_nil(fachinfo1.removed)
		@registration.fachinfo = fachinfo2
		assert_equal(@registration, fachinfo1.removed)
		assert_equal(@registration, fachinfo2.added)
		assert_equal(@registration.fachinfo_oid, 3)
		assert_nil(fachinfo2.removed)
		@registration.fachinfo = nil
		assert_equal(@registration, fachinfo2.removed)
	end
	def test_substance_names
		sequence = StubRegistrationSequence.new(1)
		expected = ["Milch", "Rahm"]
		sequence.substance_names = expected
		@registration.sequences = {
			'3434' => sequence,
		}
		assert_equal(expected, @registration.substance_names)
	end
	def test_checkout
		seq1 = Mock.new('Sequence1')
		seq2 = Mock.new('Sequence2')
		sequences = {
			"01"	=>	seq1,
			"02"	=>	seq2,
		}
		@registration.instance_variable_set('@sequences', sequences)
		seq1.__next(:checkout) { 
			assert(true)	
		}
		seq1.__next(:odba_delete) { 
			assert(true)	
		}
		seq2.__next(:checkout) { 
			assert(true)	
		}
		seq2.__next(:odba_delete) { 
			assert(true)	
		}
		@registration.checkout
		seq1.__verify
		seq2.__verify
	end
end
class TestIncompleteRegistration < Test::Unit::TestCase
	def setup
		@reg = ODDB::IncompleteRegistration.new
		@seq = StubRegistrationSequence.new(1)
		@seq.name = ''
		@reg.sequences = {'01'	=>	@seq}
	end
	def test_acceptable
		assert(!@reg.acceptable?)
		@reg.iksnr = '12345'
		assert(!@reg.acceptable?)
		@seq.atc_class = 'foo'
		assert(!@reg.acceptable?)
		@reg.iksnr = nil
		assert(!@reg.acceptable?)
		@seq.name = 'bar'
		assert(!@reg.acceptable?)
		@reg.iksnr = '12345'
		assert(!@reg.acceptable?)
		@reg.company = 'ywesee'
		assert(@reg.acceptable?)
		@seq.atc_class = nil
		assert(!@reg.acceptable?)
	end
	def test_accepted
		app = StubRegistrationApp.new
		@reg.company = StubRegistrationCompany.new('ywesee')
		@reg.iksnr = '12345'
		@reg.generic_type = :generic
		@reg.export_flag = 'Export'
		@reg.accepted!(app)
		pointer = ODDB::Persistence::Pointer.new([:registration, '12345'])
		assert_equal(pointer.creator, app.pointer)
		expected = {
			:generic_type=>:generic,
			:export_flag=>'Export',
			:company=>1,
		}
		assert_equal(expected, app.values)
		assert(@seq.accepted)
		assert_equal(@reg.pointer, app.delete_pointer)
	end
end
