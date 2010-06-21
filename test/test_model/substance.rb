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
    attr_writer :sequences, :substrate_connections
  end
  class TestSubstance < Test::Unit::TestCase
    include FlexMock::TestCase
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
    def test_add_chemical_form
      form1 = flexmock 'chemical form'
      @substance.add_chemical_form form1
      assert_equal [form1], @substance.chemical_forms
      @substance.add_chemical_form form1
      assert_equal [form1], @substance.chemical_forms
      form2 = flexmock 'chemical form'
      @substance.add_chemical_form form2
      assert_equal [form1, form2], @substance.chemical_forms
    end
    def test_add_sequence
      @substance.add_sequence("holla")
      assert_equal(["holla"], @substance.sequences)
    end
    def test_adjust_types
      ptr = flexmock 'pointer'
      ptr.should_receive(:resolve).and_return 'resolved effective form'
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
        :effective_form => ptr,
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
        :effective_form => 'resolved effective form',
      }
      assert_equal(expected, result)
    end
    def test_atc_classes
      @substance.sequences.push flexmock(:atc_class => 'Atc-Class 1'),
                                flexmock(:atc_class => 'Atc-Class 2'),
                                flexmock(:atc_class => 'Atc-Class 1')
      assert_equal ['Atc-Class 1', 'Atc-Class 2'], @substance.atc_classes
    end
    def test_checkout
      conn = flexmock 'substrate'
      conn.should_receive(:odba_delete).times(1).and_return do assert true end
      @substance.substrate_connections.store 'key', conn
      @substance.checkout
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
    def test_effective_form_writer
      form = flexmock 'effective_form'
      form.should_receive(:add_chemical_form).with(@substance).times(1)\
        .and_return do assert true end
      @substance.effective_form = form
      assert_equal form, @substance.effective_form
      form.should_receive(:remove_chemical_form).with(@substance).times(1)\
        .and_return do assert true end
      @substance.effective_form = nil
      assert_nil @substance.effective_form
    end
    def test_empty
      assert_equal true, @substance.empty?
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
    def test_format_connection_key
      fmt = @substance.format_connection_key('(+)-alfa-Tocopheroli Acetas')
      assert_equal('alfatocopheroliacetas', fmt)
      fmt = @substance.format_connection_key('1-(4-Tolyl)-Ethylis Nicotinas')
      assert_equal('14tolylethylisnicotinas', fmt)
    end
    def test_has_connection_key
      assert_equal false, @substance.has_connection_key?('a Substance')
      @substance.connection_keys.push 'asubstance'
      assert_equal true, @substance.has_connection_key?('a Substance')
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
    def test_interactions_with
      other = flexmock 'other', :has_effective_form? => false
      conn = flexmock 'connection'
      conn.should_receive(:interactions_with).with(other).times(1)\
        .and_return do assert true; ['interaction'] end
      @substance.substrate_connections.store 'conn-key', conn
      assert_equal ['interaction'], @substance.interactions_with(other)
      effective = flexmock 'effective_form', :has_effective_form? => true,
                                             :is_effective_form? => true
      effective.should_receive(:interactions_with).with(other).times(1)\
        .and_return do assert true ; ['effective interaction'] end
      @substance.effective_form = effective
      assert_equal ['interaction', 'effective interaction'],
                   @substance.interactions_with(other)
      third = flexmock 'third', :has_effective_form? => true,
                                :is_effective_form? => false,
                                :effective_form => effective
      conn.should_receive(:interactions_with).with(third).times(1)\
        .and_return do assert true; ['third interaction'] end
      conn.should_receive(:interactions_with).with(effective).times(1)\
        .and_return do assert true; ['fifth interaction'] end
      effective.should_receive(:interactions_with).with(third).times(1)\
        .and_return do assert true ; ['fourth interaction'] end
      effective.should_receive(:interactions_with).with(effective).times(1)\
        .and_return do assert true ; [] end
      assert_equal ['third interaction', 'fourth interaction', 'fifth interaction'],
                   @substance.interactions_with(third)
    end
    def test_merge
      @substance.pointer = ["!substance,12"]
      @substance.sequences = []
      composition = FlexMock.new('composition')
      act2 = flexmock 'activeagent2', :sequence => nil
      act2.should_receive(:odba_delete).times(1).and_return do assert true end
      comp2 = flexmock 'composition2', :active_agent => act2
      comp3 = flexmock 'composition3', :active_agent => nil
      sequence = FlexMock.new('sequence')
      sequence.should_receive(:compositions).and_return [composition, comp2, comp3]
      aagent = FlexMock.new('aagent') 
      other = FlexMock.new('other')
      connection = FlexMock.new('connection')
      pointer = FlexMock.new('pointer')
      narc = flexmock 'narcotic'
      narc.should_receive(:add_substance).with(@substance).times(1).and_return do
        assert true
      end
      other.should_receive(:sequences).and_return { [ sequence ] }
      other.should_receive(:narcotic).times(1).and_return narc
      other.should_receive(:narcotic=).with(nil).times(1).and_return do
        assert true
      end
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
      other.should_receive(:remove_sequence).with(sequence).times(1).and_return do
        assert true
      end
      @substance.merge(other)
      assert_equal('smc', @substance.swissmedic_code)
      assert_equal narc, @substance.narcotic
    end
    def test_name
      assert_equal('Acidum Acetylsalicylicum', @substance.name)
      @substance.descriptions.clear
    end
    def test_name2
      @substance.descriptions.store('en', 'En Name')
      @substance.descriptions.delete('lt')
      assert_equal('En Name', @substance.name)
    end
    def test_names
      assert_equal ['Acidum Acetylsalicylicum'], @substance.names
      effective = flexmock :names => ['Other Names', nil, '']
      @substance.instance_variable_set '@effective_form', effective
      assert_equal ['Acidum Acetylsalicylicum', 'Other Names'], @substance.names
    end
    def test_narcotic_writer
      narc = flexmock 'narcotic'
      narc.should_receive(:add_substance).with(@substance).times(1).and_return do
        assert true
      end
      @substance.narcotic = narc
      narc.should_receive(:remove_substance).with(@substance).times(1).and_return do
        assert true
      end
      @substance.narcotic = nil
    end
    def test_primary_connection_key
      assert_equal 'acidumacetylsalicylicum', @substance.primary_connection_key
    end
    def test_remove_chemical_form
      form = flexmock 'chemical form'
      @substance.chemical_forms.push form
      @substance.remove_chemical_form form
      assert_equal [], @substance.chemical_forms
    end
    def test_remove_sequence
      @substance.sequences = ["alloa"]
      @substance.remove_sequence("alloa")
      assert_equal([], @substance.sequences)
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
    def test_search_keys
      assert_equal ['Acidum Acetylsalicylicum'], @substance.search_keys
      @substance.effective_form = flexmock :search_keys => ['Other']
      assert_equal ['Acidum Acetylsalicylicum', 'Other'], @substance.search_keys
    end
    def test_soundex_keys
      expected = [
        'A235 A234',
      ]
      assert_equal(expected, @substance.soundex_keys)
    end
    def test_substrate_connections
      assert_equal({}, @substance.substrate_connections)
    end
    def test_to_i
      assert_equal @substance.oid, @substance.to_i
    end
    def test_unique_compare
      other = flexmock :connection_keys => ['Acidum Acetylsalicylicum'],
                       :_search_keys => []
      assert_equal true, @substance.unique_compare?(other)
      other = flexmock :connection_keys => ['Acidum Acetylsalicylicum'],
                       :_search_keys => ['Another Key']
      assert_equal true, @substance.unique_compare?(other)
      other = flexmock :connection_keys => ['Acidum Mefenamicum'],
                       :_search_keys => ['Another Key']
      assert_equal false, @substance.unique_compare?(other)
    end
  end
end
