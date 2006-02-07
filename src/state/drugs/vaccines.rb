#!/usr/bin/env ruby
# State::Drugs::Vaccines -- oddb -- 06.02.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'util/interval'
require 'view/drugs/vaccines'

module ODDB
	module State
		module Drugs
class Vaccines < State::Drugs::Global
	include IndexedInterval
	VIEW = View::Drugs::Vaccines
	DIRECT_EVENT = :vaccines
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
		@session.search_vaccines(range)
	end
end
		end
	end
end
