#!/usr/bin/env ruby
#State::Drugs::Narcotics  -- oddb -- 16.11.2005 -- spfenninger@ywesee.com

require 'state/global_predefine'
require 'util/interval'
require 'view/drugs/narcotics'

module ODDB
	module State
		module Drugs
class Narcotics < State::Drugs::Global
	include IndexedInterval
	VIEW = View::Drugs::Narcotics
	DIRECT_EVENT = :narcotics
	PERSISTENT_RANGE  = true
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
		'|unknown'=>	'|unknown',
	}
	Limited = true
	def index_lookup(range)
		lookups = range == '0-9' ? @numbers : [range]
		result = []
		lookups.each { |lookup|
			result.concat(@session.search_narcotics(lookup, @session.language)) 
		}
		result
	end
	def intervals
		@intervals or begin
		lang = @session.language
		values = ODBA.cache.index_keys("narcotics_#{lang}", 1)
		@intervals, @numbers = values.partition { |char|
				/[a-z]/i.match(char)
		}
		unless(@numbers.empty?)
			@intervals.push('0-9')
		end
		@intervals
	end
	end
end
		end
	end
end
