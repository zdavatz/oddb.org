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
	def init
		@model = @session.sequences
		super
	end
	def default_interval
	end
end
		end
	end
end
