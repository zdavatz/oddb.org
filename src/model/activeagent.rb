#!/usr/bin/env ruby
# ActiveAgent -- oddb -- 22.04.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'model/dose'

module ODDB
	class ActiveAgentCommon
		include Persistence
		attr_accessor :substance
		attr_accessor :chemical_substance, :equivalent_substance
		attr_accessor :dose, :chemical_dose, :equivalent_dose, :sequence
		def initialize(substance_name)
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
		def to_s
			[@substance, @dose].join(' ')
		end
		def update_values(values)
			super
			@pointer= @pointer.parent + [:active_agent, @substance.name]
		end
		alias :pointer_descr :to_s
		def ==(other)
			other.is_a?(ActiveAgent) \
				&& (@substance == other.substance) \
				&& (@dose == other.dose)
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
			values.each { |key, value| 
				case(key)
				when :dose, :chemical_dose, :equivalent_dose
					begin
						values[key] = Dose.new(*value) unless(value.is_a? Dose)
					rescue(StandardError)
						values.delete(key)
					end
					if(value.nil? && key != :dose)
						values[key] = nil
					end
				when :substance, :chemical_substance, :equivalent_substance
					values[key] = app.substance(value)
					if(values[key].nil? && key == :substance)
						values.delete(key) 
					end
				end
			}
			values
		end
	end
	class ActiveAgent < ActiveAgentCommon
		def substance=(substance)
			unless(substance.nil? || @substance == substance)
				if(@substance.respond_to?(:remove_sequence))
					@substance.remove_sequence(@sequence)
				end
				substance.add_sequence(@sequence)
				@substance = substance
			end
			@substance
		end
	end
	class IncompleteActiveAgent < ActiveAgentCommon
		def accepted!(app, seq_pointer)
			return if(@substance.nil? || @substance.name.empty?)
			ptr = seq_pointer + [:active_agent, @substance.name]
			hash = {
				:chemical_substance		=>	(@chemical_substance.name if @chemical_substance), 
				:equivalent_substance	=>	(@equivalent_substance.name if @equivalent_substance),
				:dose									=>	@dose,
				:chemical_dose				=>	@chemical_dose, 
				:equivalent_dose			=>	@equivalent_dose,
			}.delete_if { |key, va| va.nil? }
			app.update(ptr.creator, hash)
		end
	end
end
