#!/usr/bin/env ruby
# Dose -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/quanty'

module ODDB
	class Dose < Quanty
		alias :qty :val 
		DISABLE_DIFF = true
		def Dose.from_quanty(other)
			if other.is_a?(Quanty)
				Dose.new(other.val, other.unit)
			else
				other
			end
		end
		def initialize(qty, unit=nil)
			if (match = %r{([^/]*)/\s*(\d+([.,]\d+)?)\s*(.*)}.match(unit.to_s))
				qty = round(qty)
				div = round(match[2])
				@not_normalized = [qty, [match[1].strip, div].join(' / '), match[4]].join
				qty = qty.to_f/div.to_f
				unit = [match[1].strip,match[4].strip].join('/')
			end
			qty = round(qty)
			unit = unit.to_s.tr('L', 'l')
			fuzzy_retry = true
			strict_retry = true
			begin
				super(qty, unit)
			rescue StandardError => e
				if(fuzzy_retry)
					unit = unit[0,2]
					fuzzy_retry = false
					retry
				elsif(strict_retry)
					unit = ''
					strict_retry = false
					retry
				else
					raise
				end
			end
		end
		def to_f
			begin
				super
			rescue RuntimeError
				@val * @fact.factor
			end
		end
		def to_s
			@not_normalized or begin
				val = if(@val.is_a? Float)
					sprintf('%.3f', @val).gsub(/0+$/, '')
				else
					@val
				end
				[val, @unit].join(' ')
			end
		end
		def * (other)
			Dose.from_quanty(super)
		end
		def + (other)
			Dose.from_quanty(super)
		end
		def / (other)
			Dose.from_quanty(super)
		end
		def - (other)
			Dose.from_quanty(super)
		end
		def ** (other)
			Dose.from_quanty(super)
		end
		def ==(other)
			begin
				super
			rescue RuntimeError => e
				#puts e
				false
			end
		end
		def <=>(other)
			begin
				super
			rescue StandardError => e
				if(@unit.nil? && other.unit.nil?)
					0
				elsif(@unit.nil?)
					1
				elsif(other.unit.nil?)
					-1
				else
					@unit <=> other.unit
				end
			end
		end
		private
		def round(qty)
			qty = qty.to_s.gsub(/'/, '').gsub(',', '.')
			if(qty.to_f == qty.to_i)
				qty.to_i
			else
				qty.to_f
			end
		end
	end
end
