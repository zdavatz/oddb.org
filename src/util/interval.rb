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
			'|unknown'=>	'^a-zäÄáÁâÂàÀçÇëËéÉêÊèÈïÏíÍîÎìÌöÖóÓôÔòÒüÜúÚûÛùÙ',
		}
		FILTER_THRESHOLD = 30
		attr_reader :range
		def filter_interval
			if(@model.size > self::class::FILTER_THRESHOLD)
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
						pattern.match(item.send(*symbol))
					}
				}
			end
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
		def user_range
			range = if(self::class::PERSISTENT_RANGE)
				@session.persistent_user_input(:range)
			else
				@session.user_input(:range)
			end
			unless(self.class.const_get(:RANGE_PATTERNS).include?(range))
				range = default_interval
			end
			range
		end
		private
		def get_intervals
			@model.collect { |item| 
				self::class::RANGE_PATTERNS.collect { |range, pattern| 
					range if /^[#{pattern}]/i.match(item.send(*symbol))
				}.compact.first || '|unknown'
			}.flatten.uniq.sort
		end
		def symbol
			:to_s
		end
	end
	module IndexedInterval
		include Interval
		RANGE_PATTERNS = {
			'a'			=>	'aäÄáÁàÀâÂ',
			'b'			=>	'b',
			'c'			=>	'cçÇ',
			'd'			=>	'd',
			'e'			=>	'eëËéÉèÈêÊ',
			'f'			=>	'f',
			'g'			=>	'g',
			'h'			=>	'h',
			'i'			=>	'i',
			'j'			=>	'j',
			'k'			=>	'k',
			'l'			=>	'l',
			'm'			=>	'm',
			'n'			=>	'n',
			'o'			=>	'oöÖóÓòÒôÔ',
			'p'			=>	'p',
			'q'			=>	'q',
			'r'			=>	'r',
			's'			=>	's',
			't'			=>	't',
			'u'			=>	'uüÜúÚùÙûÛ',
			'v'			=>	'v',
			'w'			=>	'w',
			'x'			=>	'x',
			'y'			=>	'y',
			'z'			=>	'z',
			'0-9'		=>	'^a-zäÄáÁâÂàÀçÇëËéÉêÊèÈïÏíÍîÎìÌöÖóÓôÔòÒüÜúÚûÛùÙ',
		}
	def init
		super
		@filter = Proc.new { |model|
			if(@range = user_range)
				index_lookup(@range)
			else
				[]
			end
		}
	end
	def default_interval
	end
	def interval
		@range
	end
	def intervals
		('a'..'z').to_a.push('0-9')
	end
	end
end
