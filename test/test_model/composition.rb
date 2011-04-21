#!/usr/bin/env ruby
# ODDB::TestComposition -- oddb.org -- 20.04.2011 -- mhatakeyama@ywesee.com

#$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/composition'

module ODDB
  class TestComposition < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      flexmock(ODBA.cache, :next_id => 123)
      @composition = ODDB::Composition.new
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
      active_agent = flexmock('active_agent', :same_as? => true)
      @composition.instance_eval('@active_agents = [active_agent]')
      assert_equal(active_agent, @composition.active_agent('substance'))
    end
    def test_checkout
      active_agent  = flexmock('active_agent', 
                               :checkout    => 'checkout',
                               :odba_delete => 'odba_delete'
                              )
      active_agents = flexmock([active_agent], :odba_delete => 'odba_delete')
      @composition.instance_eval('@active_agents = active_agents')
      assert_equal('odba_delete', @composition.checkout)
    end
    def test_create_active_agent
      assert_kind_of(ODDB::ActiveAgent, @composition.create_active_agent('substance_name'))
    end
    def test_delete_active_agent
      active_agent = flexmock('active_agent', :same_as? => true)
      active_agents = flexmock([active_agent], :odba_isolated_store => 'odba_isolated_store')
      @composition.instance_eval('@active_agents = active_agents')
      assert_equal(active_agent, @composition.delete_active_agent('substance'))
    end
    def test_doses
      active_agent = flexmock('active_agent', 
                              :same_as? => true,
                              :dose     => 'dose'
                             )
      @composition.instance_eval('@active_agents = [active_agent]')
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
      active_agent = flexmock('active_agent', :substance => 'substance')
      @composition.instance_eval('@active_agents = [active_agent]')
      assert_equal(['substance'], @composition.substances)
    end
    def test_to_s
      active_agent = flexmock('active_agent', :to_s => 'active_agent')
      @composition.instance_eval('@active_agents = [active_agent]')
      galenic_form = flexmock('galenic_form', :to_s => 'galenic_form')
      @composition.galenic_form = galenic_form
      assert_equal('galenic_form: active_agent', @composition.to_s)
    end
    def test_multiply
      active_agent = flexmock('active_agent', 
                              :dose  => 1,
                              :dose= => nil
                             )
      @composition.instance_eval('@active_agents = [active_agent]')
      assert_kind_of(ODDB::Composition, @composition * 2)
    end
    def test_equal
      assert(@composition == @composition)
    end
    def test_comparison
      @composition.instance_eval('@active_agents = ["active_agent"]')
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

  end
end
