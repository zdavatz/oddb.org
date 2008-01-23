#!/usr/bin/env ruby
# TestSubstance	-- oddb -- 25.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/substance'
require 'util/searchterms'
require 'stub/odba'
require 'mock'
require 'odba'

module ODDB
	class Substance
		attr_writer :sequences
		attr_accessor :substrate_connections
	end
end
class TestSubstance < Test::Unit::TestCase
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
		@substance = ODDB::Substance.new
		@substance.descriptions.store('lt', "Acidum Acetylsalicylicum")
	end
	def teardown
		ODBA.storage = nil
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
			'fr'	=>	'Fr PréNom',
			'hc'  =>  'special Hcl',
			'c2'  =>  'special C2o6',
      '.E'  =>  'F.e.i.a.',
      'rm'  =>  'Faktor Ii Vom Menschen',
      'bk'  =>  'Heparinoidum (Poly(Methylis Galacturonatis Sulfas) Natricus)',
      'ds'  =>  'L-O-carnitin',
      'sc'  =>  'Extractum Sicc.',
		}
		result = @substance.adjust_types(values)
		expected = {
			'en'	=>	'En Name',
			'lt'	=>	'De Name',
			'fr'	=>	'Fr Prénom',
			'hc'  =>  'Special HCl',
			'c2'  =>  'Special C2O6',
      '.E'  =>  'F.E.I.A.',
      'rm'  =>  'Faktor II vom Menschen',
      'bk'  =>  'Heparinoidum (Poly(Methylis Galacturonatis Sulfas) Natricus)',
      'ds'  =>  'L-O-Carnitin',
      'sc'  =>  'Extractum sicc.',
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
		@substance.pointer = ["!substance,12"]
		@substance.sequences = []
		sequence = Mock.new('sequence')
		aagent = Mock.new('aagent') 
		other = Mock.new('other')
		connection = Mock.new('connection')
		pointer = Mock.new('pointer')
		other.__next(:sequences) { [ sequence ] }
		sequence.__next(:active_agent) { aagent }
		aagent.__next(:sequence) { sequence }
		aagent.__next(:substance=) { |param| 
			assert_equal(@substance, param)
		}
		aagent.__next(:odba_isolated_store) { }
		other.__next(:substrate_connections) {
			{ 'conn_key'	=>	connection }
		}
		connection.__next(:cyp_id) { 'cyp_id' }
		connection.__next(:pointer)	{ pointer }
		pointer.__next(:last_step) { ['!pointer,last.'] }
		connection.__next(:pointer=) { |param|
			assert_equal(["!substance,12", "!pointer,last."], param)
		}
		connection.__next(:cyp_id) { 'cyp_id' }
		connection.__next(:odba_isolated_store)	{ }
		other.__next(:descriptions) {
			{ 'key'	=> 'value' }
		}
		other.__next(:synonyms) { ['a_Synonym'] }
		other.__next(:descriptions) {
			{ 'key'	=> 'value' }
		}
		other.__next(:connection_keys) { ['connectionkey'] }
		@substance.merge(other)
		sequence.__verify
		aagent.__verify
		other.__verify
		connection.__verify
		pointer.__verify
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
		substance.connection_keys = ['acidummefenanicum']
		substance.descriptions.store('lt', "Acidum Acetylsalicylicum")
		assert_equal(true, substance.same_as?('ACIDUM ACETYLSALICYLICUM'))
		assert_equal(false, substance.same_as?('Acetylsalicylsäure'))
		substance.descriptions.store('de', "Acetylsalicylsäure")
		assert_equal(true, substance.same_as?('Acetylsalicylsäure'))
		assert_equal(true, substance.same_as?('Acidum Mefenanicum'))
	end
	def test_soundex_keys
		expected = [
			'A235 A234',
		]
		assert_equal(expected, @substance.soundex_keys)
	end
	def test_format_connection_key
		fmt = @substance.format_connection_key('(+)-alfa-Tocopheroli Acetas')
		assert_equal('alfatocopheroliacetas', fmt)
		fmt = @substance.format_connection_key('1-(4-Tolyl)-Ethylis Nicotinas')
		assert_equal('14tolylethylisnicotinas', fmt)
	end
end
