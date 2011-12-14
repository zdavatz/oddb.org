#!/usr/bin/env ruby
# encoding: utf-8
# ActiveAgent -- oddb -- 22.04.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'model/dose'

module ODDB
	class ActiveAgentCommon
		include Persistence
		attr_accessor :substance
		attr_accessor :chemical_substance, :equivalent_substance
		attr_accessor :dose, :chemical_dose, :equivalent_dose, :sequence
		attr_accessor :spagyric_dose, :spagyric_type, :composition
		def initialize(substance_name)
			super()
			@substance_name = substance_name
		end
		def init(app)
			self.substance = app.substance(@substance_name)
		end
		def checkout
			if(@substance.respond_to?(:remove_sequence))
				@substance.remove_sequence(@sequence)
			end
		end
		def same_as?(substance_or_oid, spag=nil)
			oid == substance_or_oid.to_i \
				||(!@substance.nil? && @substance.same_as?(substance_or_oid) \
					 && @spagyric_dose == spag)
		end
    def to_a
      [@substance, @dose]
    end
		def to_s
			to_a.compact.join(' ')
		end
		alias :pointer_descr :to_s
		def ==(other)
			other.is_a?(ActiveAgent) \
				&& [ [@substance, @dose], [@chemical_substance, @chemical_dose],
						 [@equivalent_substance, @equivalent_dose]].any? { |pair| 
							 [ [other.substance, other.dose],
								 [other.chemical_substance, other.chemical_dose],
								 [other.equivalent_substance, other.equivalent_dose],
							 ].any? { |others| 
								 others == pair && !pair.any? { |item| item.nil? }
							 }
						 }
		end
		def <=>(other)
			od = other.dose
			if(@dose.nil? && od.nil?)
				@substance <=> other.substance
			elsif(od.nil?)
				-1
			elsif(@dose.nil?)
				1
			else
				(od <=> @dose).nonzero? \
					|| (@substance <=> other.substance)
			end
		end
		private
		def adjust_types(values, app=nil)
			values = values.dup
			values.dup.each { |key, value| 
				if(value.is_a?(Persistence::Pointer))
					values.store(key, value.resolve(app))
				else
					case(key)
					when :dose, :chemical_dose, :equivalent_dose
						begin
							values[key] = Dose.new(*value) unless(value.is_a? Dose)
						rescue(StandardError)
							values.delete(key)
						end
						if(value.nil?)
							values[key] = nil
						end
					#deprecated
					when :substance, :chemical_substance, :equivalent_substance
						if(value)
							values[key] = app.substance(value)
						end
						if(values[key].nil? && key == :substance)
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
		def substance=(substance)
			unless(substance.nil? || @substance == substance)
				if(@substance.respond_to?(:remove_sequence))
					@substance.remove_sequence(@sequence)
				end
				@substance = substance
        if substance
          substance.add_sequence @sequence
        end
			end
			@substance
		end
	end
end
