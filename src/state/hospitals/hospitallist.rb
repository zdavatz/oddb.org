#!/usr/bin/env ruby
# State::Hospitals::HospitalList -- oddb -- 09.03.2005 -- jlang@ywesee.com

require 'state/hospitals/global'
require 'state/hospitals/hospital'
require 'view/hospitals/hospitallist'
require 'model/hospital'
require 'model/user'
require 'util/interval'
require 'sbsm/user'

module ODDB
	module State
		module Hospitals
class HospitalList < State::Hospitals::Global
	include Interval
	attr_reader :range
	DIRECT_EVENT = :hospitallist
	VIEW = View::Hospitals::Hospitals
	RANGE_PATTERNS = {
		'a-d'			=>	'a-däÄáÁàÀâÂçÇ',
		'e-h'			=>	'e-hëËéÉèÈêÊ',
		'i-l'			=>	'i-l',
		'm-p'			=>	'm-pöÖóÓòÒôÔ',
		'q-t'			=>	'q-t',
		'u-z'			=>	'u-züÜúÚùÙûÛ',
		'unknown'	=>	'unknown',
	}
	#REVERSE_MAP = ResultList::REVERSE_MAP
	def init
		#@model = @session.hospitals.values
		super
		userrange = @session.user_input(:range) || default_interval
		range = RANGE_PATTERNS.fetch(userrange)
		@filter = Proc.new { |model|
			model.select { |comp| 
				if(range=='unknown')
					comp.name =~ /^[^'a-zäÄáÁàÀâÂçÇëËéÉèÈêÊüÜúÚùÙûÛ']/i
				else
					/^[#{range}]/i.match(comp.name)
				end
			}
		}
		@range = range
	end
	def init
		if(!@model.is_a?(Array) || @model.empty?)
			@default_view = View::Companies::EmptyResult
		end
		filter_interval
	end
end
class HospitalResult < HospitalList
	DIRECT_EVENT = :search
	def init
		if(@model.empty?)
			@default_view = View::Hospitals::EmptyResult
		else
			super
		end
	end
end
		end
	end
end
