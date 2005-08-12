#!/usr/bin/env ruby
# State::Drugs::Sequences -- oddb -- 08.02.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'util/interval'
require 'view/drugs/sequences'

module ODDB
	module State
		module Drugs
class Sequences < State::Drugs::Global
	include Interval
	VIEW = View::Drugs::Sequences
	DIRECT_EVENT = :sequences
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
	LIMITED = true
	def init
		super
		@filter = Proc.new { |model|
			if(range = user_range)
				parts = range.to_s.split('-')
				if(parts.size > 1)
					parts = (parts.first..parts.last).to_a
				end
				sequences = parts.inject([]) { |inj, part|
					# false: do not	check all words in a sequence name, only the 
					#        beginning counts.
					inj + @session.search_sequences(part, false) 
				}
				sequences.delete_if { |seq| seq.active_packages.empty? }
				sequences
			else
				[]
			end
		}
	end
	def default_interval
	end
	def intervals
		('a'..'z').to_a.push('0-9')
	end
end
		end
	end
end
