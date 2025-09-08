#!/usr/bin/env ruby

# ODDB::ActiveAgent -- oddb.org -- 27.02.2012 -- mhatakeyama@ywesee.com
# ODDB::ActiveAgent -- oddb.org -- 22.04.2003 -- hwyss@ywesee.com

require "util/persistence"
require "model/substance"
require "model/dose"

module ODDB
  class ActiveAgentCommon
    include Persistence
    attr_accessor :substance
    attr_accessor :chemical_substance, :equivalent_substance
    attr_accessor :dose, :chemical_dose, :equivalent_dose, :sequence
    attr_accessor :composition, :more_info
    # is_active_agent is deprecated an replaced by active_agent?
    attr_reader :substance_name, :is_active_agent
    class << self
      include AccessorCheckMethod
    end
    check_class_list = {
      substance: "ODDB::Substance",
      chemical_substance: "ODDB::Substance",
      equivalent_substance: "ODDB::Substance",
      dose: "ODDB::Dose",
      chemical_dose: "ODDB::Dose",
      equivalent_dose: "ODDB::Dose",
      sequence: "ODDB::Sequence"
    }
    define_check_class_methods check_class_list
    def initialize(substance_name)
      super()
      @substance_name = substance_name
      @is_active_agent = is_a?(ActiveAgent)
    end

    def init(app)
      self.substance = app.substance(@substance_name)
    end

    def active_agent?
      is_a?(ActiveAgent)
    end

    def checkout
      if @substance.respond_to?(:remove_sequence)
        @substance.remove_sequence(@sequence)
      end
    end

    def same_as?(substance_or_oid)
      return true if substance_or_oid.respond_to?(:to_i) && substance_or_oid.to_i == substance_or_oid
      return true if substance_or_oid.respond_to?(:substance_name) && substance_or_oid == @substance_name
      return true if !@substance.nil? && @substance.same_as?(substance_or_oid)
      return true if !@substance_name.nil? && @substance_name.is_a?(String) && @substance_name.eql?(substance_or_oid)
      false
    end

    def to_a
      [@substance, @dose]
    end

    def to_s
      s = @substance ? @substance.to_s : @substance_name
      s += (" " + @dose.to_s) if @dose and @dose.to_g > 0
      s
    end
    alias_method :pointer_descr, :to_s
    def ==(other)
      other.is_a?(ActiveAgent) \
        && [[@substance, @dose], [@chemical_substance, @chemical_dose],
          [@equivalent_substance, @equivalent_dose]].any? { |pair|
             [[other.substance, other.dose],
               [other.chemical_substance, other.chemical_dose],
               [other.equivalent_substance, other.equivalent_dose]].any? { |others|
               others == pair && !pair.any? { |item| item.nil? }
             }
           }
    end

    def <=>(other)
      od = other.dose
      if @dose.nil? && od.nil?
        @substance <=> other.substance
      elsif od.nil? or !od.respond_to?(:unit)
        -1
      elsif @dose.nil? or !@dose.respond_to?(:unit)
        1
      else
        (od <=> @dose).nonzero? || (@substance <=> other.substance)
      end
    end

    private

    def adjust_types(values, app = nil)
      values = values.dup
      values.dup.each { |key, value|
        if value.is_a?(Persistence::Pointer)
          values.store(key, value.resolve(app))
        else
          case key
          when :dose, :chemical_dose, :equivalent_dose
            begin
              values[key] = Dose.new(*value) unless value.is_a? Dose
            rescue(StandardError)
              values.delete(key)
            end
            if value.nil?
              values[key] = nil
            end
          # deprecated
          when :substance, :chemical_substance, :equivalent_substance
            if value
              values[key] = app.substance(value)
            end
            if values[key].nil? && key == :substance
              values.delete(key)
            end
          end
        end
      }
      values
    end
  end

  class ActiveAgent < ActiveAgentCommon
    ODBA_PREFETCH = true
    def initialize(substance_name)
      super
    end

    def substance=(substance)
      super
      unless substance.nil? || @substance == substance
        if @substance.respond_to?(:remove_sequence)
          @substance.remove_sequence(@sequence)
        end
        @substance = substance
        if substance
          substance.add_sequence @sequence
        end
      end
    end
  end

  class InactiveAgent < ActiveAgentCommon
    ODBA_PREFETCH = true
    def initialize(substance_name)
      super
    end

    def substance=(substance)
      super
    end
  end
end
