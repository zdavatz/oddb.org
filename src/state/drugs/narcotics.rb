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
=begin
	def init
		#@model = @session.narcotics.values
		@model = @session.substances.select { |sub| sub.narcotic }
		filter_interval
	end
=end
	def index_lookup(range)
		@session.search_narcotics(range, @session.language)
	end
end
		end
	end
end
