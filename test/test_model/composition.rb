#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestComposition -- oddb.org -- 20.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/composition'
require 'stub/odba'

module ODDB
  class TestComposition <Minitest::Test
    include FlexMock::TestCase
    def setup
      @composition = ODDB::Composition.new
      @tst_name = 'substance_name'
      flexmock(ODBA.cache,
               :next_id => 123,
               :store   => nil
              )
    end
    def test_init
      pointer = flexmock('pointer', :append => 'append')
      @composition.instance_eval('@pointer = pointer')
      assert_equal('append', @composition.init('app'))
    end
    def test_active_agent
      assert_nil(@composition.active_agent('substance_or_oid'))
    end
    def test_active_agent__found
      agent = flexmock('agent', :same_as? => true, :is_active_agent => true)
      @composition.instance_eval('@active_agents = [agent]')
      assert_equal(agent, @composition.active_agent('substance'))
    end
    def test_active_agent__found_substance
      flexmock(ODBA.cache,
               :next_id => 123,
               :store   => nil
              )
      @composition.create_active_agent('substance')
      result = @composition.active_agent('substance')
      assert_kind_of(ODDB::ActiveAgent, @composition.active_agent('substance'))
    end
    def test_active_agent__does_not_raise_no_method_error
      @composition.instance_eval('@active_agents = nil')
      assert_nil(@composition.active_agent('substance_or_oid'))
    end
    def test_inactive_agent__does_not_raise_no_method_error
      @composition.instance_eval('@inactive_agents = nil')
      assert_nil(@composition.inactive_agent('substance_or_oid'))
    end
    def test_checkout
      agent  = flexmock('agent',
                               :checkout    => 'checkout',
                               :odba_delete => 'odba_delete',
                        :is_active_agent => true,
                              )
      agents = flexmock([agent], :odba_delete => 'odba_delete')
      @composition.instance_eval('@active_agents = agents')
      assert_equal('odba_delete', @composition.checkout)
    end
    def test_create_active_agent
      result = @composition.create_active_agent('substance_name')
      assert_kind_of(ODDB::ActiveAgent, result)
      assert_equal(true, result.is_active_agent)
    end
    def test_create_substance_true
      result = @composition.create_active_agent('substance_name')
      assert_kind_of(ODDB::ActiveAgent, result)
      assert_equal(true, result.is_active_agent)
    end
    def test_delete_active_agent
      agent = @composition.create_active_agent('substance_name')
      assert_kind_of(ODDB::ActiveAgent, agent)
      assert_equal(1, @composition.active_agents.size)
      result = @composition.delete_active_agent('substance_name')
      assert_equal(0, @composition.active_agents.size)
      assert_kind_of(ODDB::ActiveAgent, result)
    end
    def test_delete_inactive_agent
      agent = @composition.create_inactive_agent('substance_name')
      assert_kind_of(ODDB::InactiveAgent, agent)
      assert_equal(1, @composition.inactive_agents.size)
      result = @composition.delete_inactive_agent('substance_name')
      assert_equal(0, @composition.inactive_agents.size)
      assert_kind_of(ODDB::InactiveAgent, result)
    end
    def test_doses
      agent = flexmock('agent',
                              :same_as? => true,
                              :dose     => 'dose',
                              :is_active_agent  => true,
                             )
      @composition.instance_eval('@active_agents = [agent]')
      assert_equal(['dose'], @composition.doses)
    end
    def test_galenic_group
      galenic_form = flexmock('galenic_form', :galenic_group => 'galenic_group')
      @composition.galenic_form = galenic_form
      assert_equal('galenic_group', @composition.galenic_group)
    end
    def test_route_of_administration
      galenic_form = flexmock('galenic_form', :route_of_administration => 'route_of_administration')
      @composition.galenic_form = galenic_form
      assert_equal('route_of_administration', @composition.route_of_administration)
    end
    def test_substances
      agent = flexmock('agent', :substance => 'substance', :is_active_agent =>true)
      @composition.instance_eval('@active_agents = [agent]')
      assert_equal(['substance'], @composition.substances)
    end
    def test_to_s
      agent = flexmock('agent', :to_s => 'agent', :is_active_agent => true)
      @composition.instance_eval('@active_agents = [agent]')
      galenic_form = flexmock('galenic_form', :to_s => 'galenic_form')
      @composition.galenic_form = galenic_form
      assert_equal('galenic_form: agent', @composition.to_s)
    end
    def test_multiply
      agent = flexmock('agent',
                              :dose  => 1,
                              :dose= => nil
                             )
      @composition.instance_eval('@active_agents = [agent]')
      assert_kind_of(ODDB::Composition, @composition * 2)
    end
    def test_equal
      assert(@composition == @composition)
    end
    def test_comparison
      agent = flexmock('agent', :same_as? => true, :is_active_agent => true)
      @composition.instance_eval('@active_agents = [agent]')
      @composition.instance_eval('@galenic_form = "galenic_form"')
      assert_equal(0, @composition <=> @composition)
    end
    def test_comparison__else
      assert_equal(1, @composition <=> 123)
    end
    
    # The following testcases are for the private methods
    def test_adjust_types
      values = {'key' => 'value'}
      assert_equal(values, @composition.instance_eval('adjust_types(values)'))
    end
    def test_adjust_types__pointer
      flexmock(Persistence::Pointer).new_instances do |p|
        p.should_receive(:resolve).and_return('resolve')
      end
      values = {'key' => Persistence::Pointer.new}
      expected = {"key" => "resolve"}
      assert_equal(expected, @composition.instance_eval('adjust_types(values)'))
    end
    def test_adjust_types__galenic_form
      app    = flexmock('app', :galenic_form => 'galenic_form')
      values = {:galenic_form => 'value'}
      expected = {:galenic_form => "galenic_form"}
      assert_equal(expected, @composition.instance_eval('adjust_types(values, app)'))
    end
    def test_adjust_types__galenic_form_else
      app    = flexmock('app', :galenic_form => nil)
      values = {:galenic_form => 'value'}
      @composition.instance_eval('@galenic_form = "galenic_form"')
      expected = {:galenic_form => "galenic_form"}
      assert_equal(expected, @composition.instance_eval('adjust_types(values, app)'))
    end
    def test_replace_observer
      target = flexmock('target', :remove_sequence => 'remove_sequence')
      value  = flexmock('value', :add_sequence => 'add_sequence')
      assert_equal(value, @composition.instance_eval('replace_observer(target, value)'))
    end
    def test_active_more_info
      tst = 'more_info'
      active = @composition.create_active_agent('substance')
      assert_equal(ODDB::ActiveAgent, active.class)
      active.more_info = tst
      assert_equal(tst, active.more_info)
      active.more_info = nil
      assert_equal(nil, active.more_info)
    end

    def test_composition_corresp
      tst = 'corresp_tst'
      assert_equal('', @composition.to_s)
      @composition.corresp = tst
      assert_equal(tst, @composition.corresp)
      assert_equal('', @composition.to_s)
    end

    def test_composition_label
      tst = 'label_tst'
      assert_equal('', @composition.to_s)
      @composition.label = tst
      assert_equal(tst, @composition.to_s)
    end

    def test_composition_label_corresp
      tst_label = 'label_tst'
      tst_corresp =  'corresp'
      @composition.corresp = tst_corresp
      assert_equal(tst_corresp, @composition.corresp)
      @composition.label = tst_label
      assert_equal(tst_label, @composition.label)
      assert_equal(tst_label, @composition.to_s)
    end
  end
end
