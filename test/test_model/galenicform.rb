#!/usr/bin/env ruby
#TestGalenicForm - oddb - 25.02.2003 - hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/galenicform'
require 'odba'
require	'mock'

module ODDB
	class GalenicForm
		attr_writer :sequences
		public :adjust_types, :sequences
	end
end

module ODBA
	module Persistable
		def odba_isolated_store
		end
	end
end
class TestGalenicForm < Test::Unit::TestCase
	class Array
		include ODBA::Persistable
	end
	class Hash
		include ODBA::Persistable
	end
	class StubGroup
		attr_reader :add_called, :remove_called
		def add(form)
			@add_called = form
		end
		def remove(form)
			@remove_called = form
		end
		def pointer
			[:parent]
		end
	end
	class StubApp
		def initialize
			@galenic_groups = {}
			@galenic_forms = {}
		end
		def galenic_group(oid)
			@galenic_groups[oid] ||= StubGroup.new
		end
	end
	class StubSequence
		include ODDB::Persistence
		def galenic_form=(galform)
			if(@galform.respond_to?(:remove_sequence))
				@galform.remove_sequence(self)
			end
			galform.add_sequence(self)
			@galform = galform
		end
	end

	def setup
		ODBA.storage = Mock.new
		ODBA.storage.__next(:next_id) {
			1
		}
		ODBA.storage.__next(:next_id) {
			2
		}
		ODBA.storage.__next(:next_id) {
			3
		}
		ODBA.storage.__next(:next_id) {
			4
		}
		@galform = ODDB::GalenicForm.new
		@galform.update_values('de'=>'Tabletten')
	end
	def teardown
		ODBA.storage = nil
	end
	def test_adjust_types
		app = StubApp.new
		group = app.galenic_group(2)
		pointer = ODDB::Persistence::Pointer.new([:galenic_group, 2])
		values = {
			:de							=>	'Augensalbe',
			:galenic_group	=>	pointer,
		}
		expected = {
			:de							=>	'Augensalbe',
			:galenic_group	=>	group,
		}
		result = @galform.adjust_types(values, app)
		assert_equal(expected, result)
	end
	def test_compare
		galform = ODDB::GalenicForm.new
		galform.update_values('de'=>'Suspension')
		assert_nothing_raised { galform <=> @galform }
		assert(@galform > galform, 'Tabletten was not > Suspension')
	end
	def test_equivalent_to
		group1 = StubGroup.new
		@galform.galenic_group = group1
		galform = ODDB::GalenicForm.new
		assert_not_equal(@galform, galform)
		assert(!@galform.equivalent_to?(galform), "The GalenicForms should not be equivalent")
		galform.galenic_group = group1
		assert_not_equal(@galform, galform)
		assert(@galform.equivalent_to?(galform), "The GalenicForms should be equivalent")
		assert(galform.equivalent_to?(@galform), "The GalenicForms should be equivalent")
		galform.galenic_group = StubGroup.new
		assert_not_equal(@galform, galform)
		assert(!@galform.equivalent_to?(galform), "The GalenicForms should not be equivalent")
	end
	def test_galenic_group_writer
		group1 = StubGroup.new
		assert_nil(group1.add_called)
		@galform.galenic_group = group1
		assert_equal(group1, @galform.galenic_group)
		assert_equal(@galform, group1.add_called)
		assert_equal([:parent, :galenic_form, @galform.oid], @galform.pointer)
		assert_nil(group1.remove_called)
		group2 = StubGroup.new
		@galform.galenic_group = group2
		assert_equal(@galform, group1.remove_called)
		assert_equal(@galform, group2.add_called)
	end
	def test_init
		pointer = ODDB::Persistence::Pointer.new([:galenic_group, 1], [:galenic_form])
		@galform.pointer = pointer
		@galform.init(nil)
		puts @galform.oid
		expected = pointer.parent + [:galenic_form, @galform.oid]
		assert_equal(expected, @galform.pointer)
	end
	def test_merge
		assert_equal(0, @galform.sequence_count)
		galform = ODDB::GalenicForm.new
		a = StubSequence.new
		galform.add_sequence(a)
		@galform.merge(galform)
		assert_equal(1, @galform.sequence_count)
		assert_equal([a], @galform.sequences)
	end
	def test_remove_sequence1
		a = StubSequence.new
		b = StubSequence.new
		c = StubSequence.new
		@galform.sequences = [a, b, c]
		@galform.remove_sequence(b)
		assert_equal([a, c], @galform.sequences)
	end
	def test_remove_sequence2
		a = StubSequence.new
		b = StubSequence.new
		c = StubSequence.new
		@galform.sequences = [a, b, c]
		@galform.sequences.each { |seq|
			@galform.remove_sequence(seq)
		}
		assert_equal(0, @galform.sequences.size)
	end
	def test_sequence_count
		a = StubSequence.new
		b = StubSequence.new
		c = StubSequence.new
		assert_equal(0, @galform.sequence_count)
		@galform.add_sequence(a)
		assert_equal(1, @galform.sequence_count)
		@galform.add_sequence(b)
		assert_equal(2, @galform.sequence_count)
		@galform.remove_sequence(a)
		assert_equal(1, @galform.sequence_count)
		@galform.remove_sequence(b)
		assert_equal(0, @galform.sequence_count)
		@galform.remove_sequence(c)
		assert_equal(0, @galform.sequence_count)
	end
	def test_update_values
		assert_equal({'de'=>'Tabletten'}, @galform.descriptions.to_hash)	
		@galform.update_values(:de => 'Filmtabletten')
		assert_equal({'de'=>'Filmtabletten'}, @galform.descriptions.to_hash)	
	end
end
