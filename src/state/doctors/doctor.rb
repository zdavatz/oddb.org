#!/usr/bin/env ruby
# State::Companies::Company -- oddb -- 27.05.2003 -- maege@ywesee.com

require 'state/doctors/global'
require 'state/doctors/vcard'
require 'view/doctors/doctor'
require 'model/doctor'

module ODDB
	module State
		module Doctors
class Doctor < State::Doctors::Global
	VIEW = View::Doctors::Doctor
	EVENT_MAP = {
		:download	=>	State::Doctors::VCard,
	}
end
		end
	end
end
