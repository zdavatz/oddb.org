#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Interactions::TestBasket -- oddb.org -- 28.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/interactions/basket'

module ODDB
	module State
		module Interactions

class TestObservedInteraction < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    fachinfo = flexmock('fachinfo', :hash => 'hash')
    @interaction = ODDB::State::Interactions::Basket::ObservedInteraction.new('substance', fachinfo, 'pattern', 'match')
  end
  def test_eql
    assert(@interaction.eql?(@interaction))
    interaction = ODDB::State::Interactions::Basket::ObservedInteraction.new('substance', 'fachinfo', 'pattern', 'match')
    assert_equal(false, @interaction.eql?(interaction))
  end
  def test_hash
    assert_equal('hash', @interaction.hash)
  end
end

class TestCheck < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    cyp450s    = {}
    @substance = flexmock('substance2',
                          :substrate_connections => cyp450s,
                          :has_effective_form?   => false
                         )
    substance  = flexmock('substance1', 
                          :substrate_connections => cyp450s,
                          :has_effective_form?   => true,
                          :is_effective_form?    => false,
                          :effective_form        => @substance
                         )
    @check     = ODDB::State::Interactions::Basket::Check.new(substance, 'atc_codes')
  end
  def test_store_interaction
    interaction = flexmock('interaction', :substance => 'substance')
    storage     = {}
    expected    = [interaction]
    assert_equal(expected, @check.store_interaction(storage, interaction))
    expected    = {"substance" => [interaction]}
    assert_equal(expected, storage)
  end
  def test_add_interaction
    interaction = flexmock('interaction', :odba_instance => nil)
    assert_equal(nil, @check.add_interaction(interaction))
  end
  def test_add_interaction__cyp450inhibitorconnection
    flexmock(ODBA.cache, :next_id => 123)
    interaction = flexmock('interaction', 
                           :odba_instance => ODDB::CyP450InhibitorConnection.new('substance_name'),
                           :substance     => 'substance'
                          )
    expected = [interaction]
    assert_equal(expected, @check.add_interaction(interaction))
    expected = {"substance" => [interaction]}
    assert_equal(expected, @check.inhibitors)
  end
  def test_add_interaction__cyp450inducerconnection
    flexmock(ODBA.cache, :next_id => 123)
    interaction = flexmock('interaction', 
                           :odba_instance => ODDB::CyP450InducerConnection.new('substance_name'),
                           :substance     => 'substance'
                          )
    expected = [interaction]
    assert_equal(expected, @check.add_interaction(interaction))
    expected = {"substance" => [interaction]}
    assert_equal(expected, @check.inducers)
  end
  def test_add_interaction__observedinteraction
    flexmock(ODBA.cache, :next_id => 123)
    interaction = flexmock('interaction', 
                           :odba_instance => ODDB::State::Interactions::Basket::ObservedInteraction.new('substance', 'fachinfo', 'pattern', 'match'),
                           :substance     => 'substance'
                          )
    expected = [interaction]
    assert_equal(expected, @check.add_interaction(interaction))
    expected = {"substance" => [interaction]}
    assert_equal(expected, @check.observed)
  end
end

class TestBasekt < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf      = flexmock('lookandfeel', :lookup => 'lookup')
    atc_codes = flexmock('atc_codes', )
    substance = flexmock('substance', 
                         :substrate_connections => {},
                         :has_effective_form?   => nil
                        )
    @session  = flexmock('session', 
                         :lookandfeel => @lnf,
                         :interaction_basket => [substance],
                         :interaction_basket_atc_codes => [atc_codes],
                        )
    @model    = flexmock('model')
    @state    = ODDB::State::Interactions::Basket.new(@session, @model)
  end
  def test_init
    assert_kind_of(ODDB::State::Interactions::Basket::Check, @state.init[0])
  end
  def test_delete
    assert_kind_of(ODDB::State::Interactions::Basket::Check, @state.delete[0])
  end
  def test__observed_interactions__empty
    substance1 = flexmock('substance1', :names => ['name1', 'name2'])
    substance2 = flexmock('substance2', :names => ['name1', 'name2'])
    assert_equal([], @state._observed_interactions(substance1, substance2))
  end
  def test__observed_interactions
    doc        = flexmock('doc', :interactions => '|(name1e)|')
    flexmock(@session, :language => 'language')
    fachinfo   = flexmock('fachinfo', :language => doc)
    sequence   = flexmock('sequence', 
                          :fachinfo   => fachinfo,
                          :substances => ['substance']
                         )
    substance1 = flexmock('substance1', 
                          :names     => ['name2'],
                          :sequences => [sequence]
                         )
    substance2 = flexmock('substance2', :names => ['name1', 'name2'])
    assert_kind_of(ODDB::State::Interactions::Basket::ObservedInteraction, @state._observed_interactions(substance1, substance2)[0])
  end
  def test__observed_interactions_effective__empty
    substance3 = flexmock('substance3', 
                          :names => ['name1', 'name2'],
                          :has_effective_form? => false
                         )
    substance1 = flexmock('substance1', 
                          :names => ['name1', 'name2'],
                          :has_effective_form? => true,
                          :is_effective_form?  => false,
                          :effective_form      => substance3
                         )
    substance2 = flexmock('substance2', :names => ['name1', 'name2'])
    assert_equal([], @state._observed_interactions_effective(substance1, substance2))
  end
  def test__observed_interactions_effective
    doc        = flexmock('doc', :interactions => '|(name1e)|')
    flexmock(@session, :language => 'language')
    fachinfo   = flexmock('fachinfo', :language => doc)
    sequence   = flexmock('sequence', 
                          :fachinfo   => fachinfo,
                          :substances => ['substance']
                         )
    substance1 = flexmock('substance1', 
                          :names     => ['name2'],
                          :sequences => [sequence],
                          :has_effective_form? => false
                         )
    substance2 = flexmock('substance2', :names => ['name1', 'name2'])

    result = @state._observed_interactions_effective(substance1, substance2)
    assert_kind_of(ODDB::State::Interactions::Basket::ObservedInteraction, result[0])
  end
  def test__observed_interactions_chemical
    chemical   = flexmock('chemical', 
                          :names => ['name1', 'name2'],
                          :chemical_forms => []
                         )
    substance1 = flexmock('substance1', 
                          :names => ['name1', 'name2'],
                          :chemical_forms => [chemical]
                         )
    substance2 = flexmock('substance2', :names => ['name1', 'name2'])
    assert_equal([], @state._observed_interactions_chemical(substance1, substance2))
  end
  def test_observed_interactions
    chemical   = flexmock('chemical', 
                          :names => ['name1', 'name2'],
                          :chemical_forms => []
                         )
    substance3 = flexmock('substance3', 
                          :names => ['name1', 'name2'],
                          :has_effective_form? => false
                         )
    substance1 = flexmock('substance1', 
                          :names => ['name1', 'name2'],
                          :has_effective_form? => true,
                          :is_effective_form?  => false,
                          :effective_form      => substance3,
                          :chemical_forms      => [chemical]
                         )
    substance2 = flexmock('substance2', :names => ['name1', 'name2'])

    assert_equal([], @state.observed_interactions(substance1, substance2))
  end
  def test_calculate_interactions
    chemical   = flexmock('chemical', 
                          :names => ['name1', 'name2'],
                          :chemical_forms => []
                         )
    substance3 = flexmock('substance3', 
                          :names => ['name1', 'name2'],
                          :has_effective_form? => false,
                          :substrate_connections => {}
                         )
    substance1 = flexmock('substance1', 
                          :names => ['name1', 'name2'],
                          :substrate_connections => {},
                          :has_effective_form? => true,
                          :is_effective_form?  => false,
                          :effective_form      => substance3,
                          :chemical_forms      => [chemical],
                          :interactions_with   => ['interaction']
                         )
    substance2 = flexmock('substance2', 
                          :names => ['name1', 'name2'],
                          :substrate_connections => {},
                          :has_effective_form? => true,
                          :is_effective_form?  => false,
                          :effective_form      => substance3,
                          :chemical_forms      => [chemical],
                          :interactions_with   => ['interaction']
                         )

    flexmock(@session, :interaction_basket => [substance1, substance2])
    result = @state.calculate_interactions
    assert_equal(@state.instance_eval('@model'), result)
    assert_equal(1, result.length)
    assert_kind_of(ODDB::State::Interactions::Basket::Check, result[0])
  end
  def test_calculate_interactions__observed_interactions
    chemical   = flexmock('chemical', 
                          :names => ['name1', 'name2'],
                          :chemical_forms => []
                         )
    doc        = flexmock('doc', :interactions => '|(name1e)|')
    flexmock(@session, :language => 'language')
    fachinfo   = flexmock('fachinfo', :language => doc)
    sequence   = flexmock('sequence', 
                          :fachinfo   => fachinfo,
                          :substances => ['substance']
                         )
    substance1 = flexmock('substance1', 
                          :names     => ['name2'],
                          :sequences => [sequence],
                          :has_effective_form?   => false,
                          :substrate_connections => {},
                          :chemical_forms        => [chemical],
                          :interactions_with     => ['interaction']
                         )
    substance2 = flexmock('substance2', 
                          :names => ['name1', 'name2'],
                          :substrate_connections => {},
                          :has_effective_form?   => false,
                          :chemical_forms        => [chemical],
                          :interactions_with     => ['interaction']
                         )

    flexmock(@session, :interaction_basket => [substance1, substance2])
    result = @state.calculate_interactions
    assert_equal(@state.instance_eval('@model'), result)
    assert_equal(1, result.length)
    assert_kind_of(ODDB::State::Interactions::Basket::Check, result[0])
  end
end


		end # Interactions
	end # State
end # ODDB
