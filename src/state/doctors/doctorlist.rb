#!/usr/bin/env ruby
# State::Doctors::DoctorList -- oddb -- 26.05.2003 -- mhuggler@ywesee.com

require 'state/doctors/global'
require 'state/doctors/doctor'
require 'view/doctors/doctorlist'
require 'model/doctor'
require 'model/user'
require 'sbsm/user'

module ODDB
	module State
		module Doctors
class DoctorList < State::Doctors::Global
	DIRECT_EVENT = :doctorlist
	VIEW = View::Doctors::Doctors
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
		super
		if(self.paged?)
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
	end
	def default_interval
		intervals.first
	end
	def get_intervals
		@model.collect { |doctor| 
			rng = RANGE_PATTERNS.select { |key, pattern| 
				/^[#{pattern}]/i.match(doctor.name)
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
		@model.size > 100
	end
end
class DoctorResult < DoctorList
	DIRECT_EVENT = :search
	def init
		if(@model.empty?)
			@default_view = View::Doctors::EmptyResult
		else
			super
		end
	end
end
		end
	end
end
