#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Composition -- oddb.org -- 29.02.2012 -- mhatakeyama@ywesee.com
# ODDB::Composition -- oddb.org -- 28.04.2008 -- hwyss@ywesee.com

require 'util/persistence'
require 'model/activeagent'
require 'model/substance'

module ODDB
  class Composition
    include Persistence
    include Comparable
    attr_accessor :sequence, :source, :label, :corresp
    attr_reader :galenic_form, :agents, :excipiens
    # For a long time we were only interested in active_agents
    # in 2015 we decided to introduce Hilfsstoffe besides Wirkstoffe (as we did in oddb2xml --calc)
    # As we could not change the name of active_agents in the database to agents, you should
    # always replace in your mind @active_agents by @agents
    def initialize
      @excipiens = nil
      @agents = []
      @active_agents = [] # Will soon become obsolete after running
      @parts = []
      super
    end
    def add_excipiens(substance)
      raise "can only add a substance as excipiens" unless substance.is_a?(ODDB::Substance) or
          (substance.is_a?(ODDB::ActiveAgent) and not substance.is_active_agent)
      @excipiens = substance
    end
    def init(app)
      cleanup_old_active_agent
      @pointer.append(@oid)
    end
    # fix_pointers is needed to enable calling @app.create(sequence.pointer + :composition) in
    # plugin/swissmedic.rb when running UnitTests
    def fix_pointers
      cleanup_old_active_agent
      @pointer = @sequence.pointer + [:composition, @oid]
      odba_store
    end
    def active_agents # aka Wirkstoffe
      cleanup_old_active_agent
      @agents.find_all { |active| active.is_active_agent }
    end
    def inactive_agents # aka Hilfsstoffe
      cleanup_old_active_agent
      @agents.find_all { |active| not active.is_active_agent }
    end
    def active_agent(substance_or_oid)
      cleanup_old_active_agent
      @agents.find { |active| active.same_as?(substance_or_oid) }
    end
    def get_auxiliary_substance(substance_or_oid)
      cleanup_old_active_agent
      @agents.find { |active| active.same_as?(substance_or_oid) and not active.is_active_agent}
    end
    def checkout
      self.galenic_form = nil
      cleanup_old_active_agent
      @agents.dup.each { |act|
        act.checkout
        act.odba_delete
      }
      @agents.odba_delete
    end
    def create_active_agent(substance_name, is_active_agent = true)
      active = @agents.find { |active| active.same_as?(substance_or_oid) and active.is_active_agent == is_active_agent }
      return active unless active == nil
      active = ActiveAgent.new(substance_name, is_active_agent)
      composition = self
      active.sequence = @sequence
      @agents.push(active)
      @agents.odba_isolated_store
      self.odba_store
      active
    end
    def delete_active_agent(substance_or_oid, is_active_agent = true)
      cleanup_old_active_agent
      active = @agents.find { |active| active.same_as?(substance_or_oid) and is_active_agent == active.is_active_agent}
      if(active)
        @agents.delete(active)
        @agents.odba_isolated_store
        active
      end
    end
    def doses
      active_agents.collect { |agent| agent.dose }
    end
    def galenic_form=(galform)
      @galenic_form = replace_observer(@galenic_form, galform)
    end
    def galenic_group
      @galenic_form.galenic_group if @galenic_form.respond_to?(:galenic_group)
    end
    def route_of_administration
      @galenic_form.route_of_administration if(@galenic_form)
    end
    def substances
      if active_agents.is_a?(Array)
        active_agents.collect { |agent| agent.substance }
      else
        []
      end
    end
    def to_s
      cleanup_old_active_agent
      str = @agents.join(', ')
      if @galenic_form
        str = "%s: %s" % [@galenic_form, str]
      end
      str = str.length > 0 ? @label + ': ' + str : @label if @label
      str
    end
    def *(factor)
      result = dup
      result.active_agents = @agents.collect do |act|
        factored = act.dup
        factored.dose = if act.dose
                          act.dose * factor
                        else
                          0 * factor
                        end
        factored
      end
      result
    end
    def ==(other)
      other.object_id == object_id \
        || other.is_a?(Composition) \
				&& !@galenic_form.nil? \
				&& !other.galenic_form.nil? \
        && other.galenic_form.equivalent_to?(@galenic_form) \
        && other.active_agents.size == @agents.size \
        && other.active_agents.sort == @agents.sort
    end
    def <=>(other)
      if other.is_a? Composition and @agents.respond_to?(:sort)
        [@agents.sort, @galenic_form] \
          <=> [other.active_agents.sort, other.galenic_form]
      else
        1
      end
    end
		private
    def cleanup_old_active_agent
      @agents ||= []
      if @agents.size == 0 and @active_agents.size > 0
        @agents = @active_agents
        @active_agents = []
        @agents.odba_isolated_store
        @active_agents.odba_isolated_store
        self.odba_isolated_store
      end
    end
    def adjust_types(values, app=nil)
      values = values.dup
      values.dup.each { |key, value|
        if(value.is_a?(Persistence::Pointer))
          values[key] = value.resolve(app)
        else
          case(key)
          when :galenic_form
            values[key] = if(galform = app.galenic_form(value))
              galform
            else
              @galenic_form
            end
          end 
        end
      }
      values
    end
    def	replace_observer(target, value)
      if(target.respond_to?(:remove_sequence))
        target.remove_sequence(@sequence)
      end
      if(value.respond_to?(:add_sequence))
        value.add_sequence(@sequence)
      end
      target = value
    end	
    protected
    attr_writer :active_agents
  end
end
