#!/usr/bin/env ruby
# State::Doctors::Global -- oddb -- 17.09.2004 --jlang@ywesee.com

require 'state/doctors/init'
require 'state/legalnote'

module ODDB
	module State
		module Doctors
class Global < State::Global
	HOME_STATE = State::Doctors::Init
	ZONE = :doctors
	def zone_navigation
		[]
	end
	def legal_note
		State::Doctors::LegalNote.new(@session, nil)
	end
end
		end
	end
end
