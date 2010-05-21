#!/usr/bin/env ruby
# TestSubstance	-- oddb -- 25.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'model/substance'
require 'util/searchterms'
require 'flexmock'

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
		subst_conn1 = FlexMock.new('subst_conn1')
		subst_conn2 = FlexMock.new('subst_conn2')
		substance1 = FlexMock.new('substance1')
		substance2 = FlexMock.new('substance2')
		interaction1 = FlexMock.new('interaction1')
		interaction2 = FlexMock.new('interaction2')
		interaction3 = FlexMock.new('interaction3')
		substances = [ substance1, substance2 ]
		@substance.substrate_connections = {
			'cyp450_id1'	=>	subst_conn1,
			'cyp450_id2'	=>	subst_conn2,
		}
		subst_conn1.should_receive(:interactions_with).with(substance1)\
      .times(1).and_return {
      assert true
			[]
		}
		subst_conn1.should_receive(:interactions_with).with(substance2)\
      .times(1).and_return {
      assert true
			[]
		}
		subst_conn2.should_receive(:interactions_with).with(substance1)\
      .times(1).and_return {
      assert true
			[ interaction1 ]	
		}
		subst_conn2.should_receive(:interactions_with).with(substance2)\
      .times(1).and_return {
			assert true
			[ interaction2, interaction3 ]
		}
		result = @substance.interaction_connections(substances)		
		expected = {
			"cyp450_id1"	=>	[],
			"cyp450_id2"	=>	[ interaction1, interaction2, interaction3 ]
		}
		assert_equal(expected, result)
	end
	def test_remove_sequence
		@substance.sequences = ["alloa"]
		@substance.remove_sequence("alloa")
		assert_equal([], @substance.sequences)
	end
	def test_merge
		@substance.pointer = ["!substance,12"]
		@substance.sequences = []
    composition = FlexMock.new('composition')
		sequence = FlexMock.new('sequence')
    sequence.should_receive(:compositions).and_return [composition]
		aagent = FlexMock.new('aagent') 
		other = FlexMock.new('other')
		connection = FlexMock.new('connection')
		pointer = FlexMock.new('pointer')
		other.should_receive(:sequences).and_return { [ sequence ] }
    other.should_receive(:narcotic).times(1)
    other.should_receive(:swissmedic_code).times(1).and_return 'smc'
    other.should_receive(:casrn).times(1).and_return 'casrn'
    act = FlexMock.new('active-agent')
    act.should_receive(:sequence).and_return(sequence)
    act.should_receive(:substance=).with(@substance).times(1)
    act.should_receive(:odba_isolated_store)
    composition.should_receive(:active_agent).with(other).and_return(act)
		sequence.should_receive(:active_agent).and_return { aagent }
		aagent.should_receive(:sequence).and_return { sequence }
		aagent.should_receive(:substance=).and_return { |param| 
			assert_equal(@substance, param)
		}
		aagent.should_receive(:odba_isolated_store).and_return { }
		other.should_receive(:substrate_connections).and_return {
			{ 'conn_key'	=>	connection }
		}
		connection.should_receive(:cyp_id).and_return { 'cyp_id' }
		connection.should_receive(:pointer).and_return	{ pointer }
		pointer.should_receive(:last_step).and_return { ['!pointer,last.'] }
		connection.should_receive(:pointer=).and_return { |param|
			assert_equal(["!substance,12", "!pointer,last."], param)
		}
		connection.should_receive(:cyp_id).and_return { 'cyp_id' }
		connection.should_receive(:odba_isolated_store).and_return	{ }
		other.should_receive(:descriptions).and_return {
			{ 'key'	=> 'value' }
		}
		other.should_receive(:synonyms).and_return { ['a_Synonym'] }
		other.should_receive(:descriptions).and_return {
			{ 'key'	=> 'value' }
		}
		other.should_receive(:connection_keys).and_return { ['connectionkey'] }
		@substance.merge(other)
    assert_equal('smc', @substance.swissmedic_code)
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
