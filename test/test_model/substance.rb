#!/usr/bin/env ruby
# TestSubstance	-- oddb -- 25.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/substance'
require 'mock'

module ODDB
	class Substance
		attr_writer :sequences
		attr_accessor :substrate_connections
	end
end

class TestSubstance < Test::Unit::TestCase
	def setup
		@substance = ODDB::Substance.new
		@substance.descriptions.store('lt', "Acidum Acetylsalicylicum")
	end
	def test_initialize
		assert_not_nil(@substance.oid)
	end
	def test_add_sequence
		@substance.add_sequence("holla")
		assert_equal(["holla"], @substance.sequences)
	end
	def test_adjust_types
		values = { 
			'en'	=>	'EN NAME',
			'lt'	=>	'DE NAME',
		}
		result = @substance.adjust_types(values)
		expected = {
			'en'	=>	'En Name',
			'lt'	=>	'De Name',
		}
		assert_equal(expected, result)
	end
	def test_compare #test_<=>
		assert_equal(0, @substance <=> "ACIDUM ACETYLSALICYLICUM")
		assert_equal(-1, @substance <=> "BCIDUM ACETYLSALICYLICUM")
		assert_equal(+1, @substance <=> "AbIDUM ACETYLSALICYLICUM")
		assert_equal(0, @substance <=> @substance)
	end
	def test_create_cyp450substrate
		@substance.create_cyp450substrate('cyp_id')
		result = @substance.substrate_connections.keys
		assert_equal(['cyp_id'], result)
	end
	def test_cyp450substrate
		@substance.substrate_connections = {
			'id'			=>	'subs',
			'cyp_id'	=>	'substance'
		}
		result = @substance.cyp450substrate('cyp_id')
		assert_equal('substance', result)
	end
	def test_delete_cyp450substrate
		@substance.substrate_connections = {
			'id'			=>	'subs',
			'cyp_id'	=>	'substance'
		}
		result = @substance.substrate_connections
		assert_equal(2, result.size)
		@substance.delete_cyp450substrate('cyp_id')
		assert_equal(1, result.size)
	end
	def test_interaction_connections
		result = @substance.interaction_connections([])		
		assert_equal({}, result)
	end
	def test_interaction_connections2
		subst_conn1 = Mock.new('subst_conn1')
		subst_conn2 = Mock.new('subst_conn2')
		substance1 = Mock.new('substance1')
		substance2 = Mock.new('substance2')
		interaction1 = Mock.new('interaction1')
		interaction2 = Mock.new('interaction2')
		interaction3 = Mock.new('interaction3')
		substances = [ substance1, substance2 ]
		@substance.substrate_connections = {
			'cyp450_id1'	=>	subst_conn1,
			'cyp450_id2'	=>	subst_conn2,
		}
		subst_conn1.__next(:interactions_with) { |param|
			assert_equal(substance1, param)
			[]
		}
		subst_conn1.__next(:interactions_with) { |param|
			assert_equal(substance2, param)
			[]
		}
		subst_conn2.__next(:interactions_with) { |param|
			assert_equal(substance1, param)
			[ interaction1 ]	
		}
		subst_conn2.__next(:interactions_with) { |param|
			assert_equal(substance2, param)
			[ interaction2, interaction3 ]
		}
		result = @substance.interaction_connections(substances)		
		expected = {
			"cyp450_id1"	=>	[],
			"cyp450_id2"	=>	[ interaction1, interaction2, interaction3 ]
		}
		assert_equal(expected, result)
		subst_conn1.__verify
		subst_conn2.__verify
		substance1.__verify
		substance2.__verify
		interaction1.__verify
		interaction2.__verify
		interaction3.__verify
	end
	def test_remove_sequence
		@substance.sequences = ["alloa"]
		@substance.remove_sequence("alloa")
		assert_equal([], @substance.sequences)
	end
	def test_merge
		@substance.sequences = []
		sequence = Mock.new('sequence')
		aagent = Mock.new('aagent') 
		other = Mock.new('other')
		connection = Mock.new('connection')
		other.__next(:sequences) { [ sequence ] }
		sequence.__next(:active_agent) { aagent }
		aagent.__next(:substance=) { |param| 
			assert_equal(@substance, param)
		}
		other.__next(:substrate_connections) {
			{ 'conn_key'	=>	connection }
		}
		connection.__next(:cyp_id) { 'cyp_id' }
		connection.__next(:cyp_id) { 'cyp_id' }
		other.__next(:descriptions) {
			{ 'key'	=> 'value' }
		}
		other.__next(:connection_key) { 'connection_key' }
		@substance.merge(other)
		sequence.__verify
		aagent.__verify
		other.__verify
		connection.__verify
	end
	def test_name
		assert_equal('Acidum Acetylsalicylicum', @substance.name)
	end
	def test_name2
		@substance.descriptions.store('en', 'En Name')
		@substance.descriptions.delete('lt')
		assert_equal('En Name', @substance.name)
	end
	def test_equal_string
		assert_equal(@substance, 'Acidum Acetylsalicylicum', 'Substance did not equal exact String')
		assert_equal(@substance, 'ACIDUM ACETYLSALICYLICUM', 'Substance did not equal uppercase String')
		assert_equal(@substance, 'acidum acetylsalicylicum', 'Substance did not equal lowercase String')
	end
	def test_equal_substance
		substance = ODDB::Substance.new
		substance.descriptions.store('lt', 'acidum acetylsalicylicum')
		assert_equal(@substance, substance)
		substance = ODDB::Substance.new
		substance.descriptions.store('lt', 'ACIDUM ACETYLSALICYLICUM')
		assert_equal(@substance, substance)
	end
	def test_similar_name
		assert_equal(false, @substance.similar_name?("ACIDUM MEFENAMICUM"))
		assert_equal(true, @substance.similar_name?("ACIDU ACETYLSALIKUM"))
	end
	def test_same_as
		substance = ODDB::Substance.new
		substance.connection_key = 'ACIDUM Mefenanicum'
		substance.descriptions.store('lt', "Acidum Acetylsalicylicum")
		assert_equal(true, substance.same_as?('ACIDUM ACETYLSALICYLICUM'))
		assert_equal(false, substance.same_as?('Acetylsalicylsäure'))
		substance.descriptions.store('de', "Acetylsalicylsäure")
		assert_equal(true, substance.same_as?('Acetylsalicylsäure'))
		assert_equal(true, substance.same_as?('Acidum Mefenanicum'))
	end
end
