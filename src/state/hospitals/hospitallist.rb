#!/usr/bin/env ruby
# State::Hospitals::HospitalList -- oddb -- 09.03.2005 -- jlang@ywesee.com

require 'state/hospitals/global'
require 'state/hospitals/hospital'
require 'view/hospitals/hospitallist'
require 'model/hospital'
require 'model/user'
require 'sbsm/user'

module ODDB
	module State
		module Hospitals
class HospitalList < State::Hospitals::Global
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
	def default_interval
		intervals.first
	end
	def get_intervals
		@model.collect { |hospital| 
			rng = RANGE_PATTERNS.select { |key, pattern| 
				/^[#{pattern}]/i.match(hospital.name)
			}.first
			rng.nil? ? 'unknown' : rng.first
		}.compact.uniq.sort
	end
	def interval
		@interval ||= self::class::RANGE_PATTERNS.index(@range)
	end	
	def intervals
		@intervals ||= get_intervals
	end	
	def paged?
		@model.size > 10
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
