#!/usr/bin/env ruby
# Interval -- oddb -- 03.07.2003 -- hwyss@ywesee.com 

module ODDB
	module Interval
		PERSISTENT_RANGE = false
		RANGE_PATTERNS = {
			'a-d'			=>	'a-däÄáÁâÂàÀçÇ',
			'e-h'			=>	'e-hëËéÉêÊèÈ',
			'i-l'			=>	'i-lïÏíÍîÎìÌ',
			'm-p'			=>	'm-pöÖóÓôÔòÒ',
			'q-t'			=>	'q-t',
			'u-z'			=>	'u-züÜúÚûÛùÙ',
			'|unknown'=>	nil,
		}
		attr_reader :range
		def init
			super
			user_range = if(self::class::PERSISTENT_RANGE)
				@session.persistent_user_input(:range)
			else
				@session.user_input(:range)
			end
			@range = self::class::RANGE_PATTERNS.fetch(user_range) {
				self::class::RANGE_PATTERNS[default_interval]
			}
			pattern = if(@range=='|unknown')
				/^[^a-zäÄáÁâÂàÀçÇëËéÉêÊèÈïÏíÍîÎìÌöÖóÓôÔòÒüÜúÚûÛùÙ]/i
			elsif(@range)
				/^[#{@range}]/i
			else
				/^$/
			end
			@filter = Proc.new { |model|
				model.select { |item| 
					pattern.match(item.send(symbol))
				}
			}
			@range = range
		end
		def default_interval
			intervals.first || 'a-d'
		end
		def interval
			@interval ||= self::class::RANGE_PATTERNS.index(@range)
		end
		def intervals
			@intervals ||= get_intervals
		end
		private
		def get_intervals
			@model.collect { |item| 
				self::class::RANGE_PATTERNS.collect { |range, pattern| 
					range if /^[#{pattern}]/i.match(item.send(symbol))
				}.compact.first || '|unknown'
			}.flatten.uniq.sort
		end
		def symbol
			:to_s
		end
	end
end
