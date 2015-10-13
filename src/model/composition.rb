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
    attr_accessor :sequence, :source, :label, :corresp, :active_agents, :inactive_agents
    attr_reader :galenic_form, :excipiens
    # For a long time we were only interested in active_agents
    # in 2015 we decided to introduce Hilfsstoffe besides Wirkstoffe (as we did in oddb2xml --calc)
    def initialize
      @excipiens = nil
      @active_agents = []
      @inactive_agents = []
      @parts = []
      @cleaned = false
      super
    end
    def add_excipiens(substance)
      raise "can only add a substance as excipiens. Is #{substance.class}" unless substance.is_a?(ODDB::Substance) or
          substance.is_a?(ODDB::InactiveAgent)
      @excipiens = substance
    end
    def init(app)
      @pointer.append(@oid)
    end
    # fix_pointers is needed to enable calling @app.create(sequence.pointer + :composition) in
    # plugin/swissmedic.rb when running UnitTests
    def fix_pointers
      @pointer = @sequence.pointer + [:composition, @oid]
      odba_store
    end
    def active_agents # aka Wirkstoffe
      @active_agents || []
    end
    def inactive_agents
      @inactive_agents || []
    end
    def active_agent(substance_or_oid)
      active_agents.find { |active| active.same_as?(substance_or_oid) }
    end
    def inactive_agent(substance_or_oid)
      inactive_agents.find { |active| active.same_as?(substance_or_oid) }
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
      return active unless active == nil
      active = ActiveAgent.new(substance_name)
      composition = self
      active.sequence = @sequence
      @active_agents.push(active)
      @active_agents.odba_isolated_store
      self.odba_store
      active
    end
    def delete_active_agent(substance_or_oid)
      active = active_agent(substance_or_oid)
      if(active)
        @active_agents.delete(active)
        @active_agents.odba_isolated_store
        active
      end
    end
    def create_inactive_agent(substance_name)
      active = inactive_agent(substance_name)
      return active unless active == nil
      active = InactiveAgent.new(substance_name)
      composition = self
      active.sequence = @sequence
      @inactive_agents.push(active)
      @inactive_agents.odba_isolated_store
      self.odba_store
      active
    end
    def delete_inactive_agent(substance_or_oid)
      active = inactive_agent(substance_or_oid)
      if(active)
        @inactive_agents.delete(active)
        @inactive_agents.odba_isolated_store
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
      str = @active_agents.join(', ')
      if @galenic_form
        str = "%s: %s" % [@galenic_form, str]
      end
      str = str.length > 0 ? @label + ': ' + str : @label if @label
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
      if other.is_a? Composition and @active_agents.respond_to?(:sort)
        [@active_agents.sort, @galenic_form] \
          <=> [other.active_agents.sort, other.galenic_form]
      else
        1
      end
    end
    def cleanup_old_active_agent
      if @inactive_agents and @inactive_agents.class != Array
        $stdout.puts "cleanup_old_active_agent. Forcing inactive_agents from class #{@inactive_agents.class} => Array"
        @inactive_agents = []
      end
      unless sequence.registration.expiration_date  and sequence.registration.expiration_date > Date.today
        $stdout.puts "cleanup_old_active_agent. Skipping inactive registration #{reg.iksnr} expiration #{sequence.registration.expiration_date.inspect}"
        return
      end
      @active_agents ||= []
      @inactive_agents ||= []
      @inactive_agents += @active_agents.find_all{|agent| agent and agent.respond_to?(:is_active_agent) and agent.is_active_agent == false }
      @active_agents.delete_if{ |agent| agent == nil or (!agent.respond_to?(:is_active_agent)) or  agent.is_active_agent == false }
      @active_agents.each{ |agent| agent.is_active_agent = true unless agent and agent.respond_to?(:is_active_agent) and agent.is_active_agent}
      @inactive_agents.uniq! # remove duplicate if running twice
      @cleaned = true
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
