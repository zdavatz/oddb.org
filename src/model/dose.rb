#!/usr/bin/env ruby
# Dose -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/quanty'

module ODDB
	class Dose < Quanty
		include Comparable
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
		  np = '-?[0-9]+(?:[.,][0-9]+)?' ## numerical pattern
			qty_str = ''
			if(match = %r{(#{np})\s*-\s*(#{np})}.match(qty.to_s))
				qty = round(match[1].to_f)..round(match[2].to_f)
			end
			if(qty.is_a?(Range))
				qty_str = "#{qty.first}-#{qty.last}"
				qty = (qty.first + qty.last) / 2.0
				@not_normalized = [qty_str, unit].compact.join(' ')
			end
			if(match = %r{([^/]*)/\s*(#{np})\s*(.*)}.match(unit.to_s))
				qty_str = round(qty).to_s
				div = round(match[2])
				@not_normalized = [
					qty_str, 
					[match[1].strip, div].join(' / '), 
					match[3],
				].join
				qty = qty.to_f/div.to_f
				unit = [match[1].strip,match[3].strip].join('/')
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
		def to_i
			@val.to_i
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
		def want(unit)
			Dose.from_quanty(super)
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
=begin
		def ==(other)
			begin
				 other && (@val * 1000).round == (adjust(other) * 1000).round
			rescue StandardError
				false
			end
		end
=end
		def <=>(other)
			begin
				(@val * 1000).round <=> (adjust(other) * 1000).round
			rescue StandardError
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
  module Drugs
    class Dose < ODDB::Dose; end
  end
end
