#!/usr/bin/env ruby
# State::Companies::Company -- oddb -- 27.05.2003 -- mhuggler@ywesee.com

require 'state/doctors/global'
require 'view/doctors/doctor'
require 'model/doctor'

module ODDB
	module State
		module Doctors
class Doctor < State::Doctors::Global
	VIEW = View::Doctors::Doctor
	LIMITED = false
end
		end
	end
end
