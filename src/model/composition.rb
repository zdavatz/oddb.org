#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Composition -- oddb.org -- 17.02.2012 -- mhatakeyama@ywesee.com
# ODDB::Composition -- oddb.org -- 28.04.2008 -- hwyss@ywesee.com

require 'util/persistence'
require 'model/activeagent'

module ODDB
  class Composition
    include Persistence
    include Comparable
    attr_accessor :sequence, :source, :label
    attr_reader :galenic_form, :active_agents
    def initialize
      @active_agents = []
      @parts = []
      super
    end
    def init(app)
      @pointer.append(@oid)
    end
    def active_agent(substance_or_oid, spag=nil)
      @active_agents.find { |active| active.same_as?(substance_or_oid, spag) }
    end
    def checkout
      self.galenic_form = nil
      @active_agents.dup.each { |act|
        act.checkout
        act.odba_delete
      }
      @active_agents.odba_delete
    end
    def create_active_agent(substance_name)
      active = active_agent(substance_name)
      return active unless active.nil?
      active = ActiveAgent.new(substance_name)
      active.composition = self
      active.sequence = @sequence
      @active_agents.push(active)
      active
    end
    def delete_active_agent(substance)
      if(active = active_agent(substance))
        @active_agents.delete(active)
        @active_agents.odba_isolated_store
        active
      end
    end
    def doses
      @active_agents.collect { |agent| agent.dose }
    end
    def galenic_form=(galform)
      @galenic_form = replace_observer(@galenic_form, galform)
    end
    def galenic_group
      @galenic_form.galenic_group if(@galenic_form)
    end
    def route_of_administration
      @galenic_form.route_of_administration if(@galenic_form)
    end
    def substances
      if @active_agents.is_a?(Array)
        @active_agents.collect { |agent| agent.substance }
      else
        []
      end
    end
    def to_s
      str = @active_agents.join(', ')
      if @galenic_form
        str = "%s: %s" % [@galenic_form, str]
      end
      str
    end
    def *(factor)
      result = dup
      result.active_agents = @active_agents.collect do |act|
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
        && other.active_agents.size == @active_agents.size \
        && other.active_agents.sort == @active_agents.sort
    end
    def <=>(other)
      if other.is_a? Composition
        [@active_agents.sort, @galenic_form] \
          <=> [other.active_agents.sort, other.galenic_form]
      else
        1
      end
    end
		private
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
