#!/usr/bin/env ruby
# State::Doctors::Global -- oddb -- 17.09.2004 --jlang@ywesee.com

require 'state/doctors/init'

module ODDB
	module State
		module Doctors
class Global < State::Global
	HOME_STATE = State::Doctors::Init
	ZONE = :doctors
	def zone_navigation
		[
			State::Doctors::DoctorList,
		]
	end
end
		end
	end
end
