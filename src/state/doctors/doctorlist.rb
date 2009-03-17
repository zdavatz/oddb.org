#!/usr/bin/env ruby
# State::Doctors::DoctorList -- oddb -- 26.05.2003 -- mhuggler@ywesee.com

require 'state/doctors/global'
require 'state/doctors/doctor'
require 'view/doctors/doctorlist'
require 'util/interval'
require 'model/doctor'
require 'model/user'
require 'sbsm/user'

module ODDB
	module State
		module Doctors
class DoctorList < State::Doctors::Global
  include Interval
	DIRECT_EVENT = :doctorlist
	VIEW = View::Doctors::Doctors
	LIMITED = false
	FILTER_THRESHOLD = 10
  def init
    filter_interval
  end
  def paged?
    @model.size > FILTER_THRESHOLD
  end
  def symbol
    :name
  end
end
class DoctorResult < DoctorList
	DIRECT_EVENT = :result
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
