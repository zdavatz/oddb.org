#!/usr/bin/env ruby
# State::Doctors::Global -- oddb -- 17.09.2004 --jlang@ywesee.com

require 'state/doctors/init'
require 'state/doctors/vcard'
require 'state/doctors/limit'
require 'state/legalnote'

module ODDB
	module State
		module Doctors
class Global < State::Global
	HOME_STATE = State::Doctors::Init
	ZONE = :doctors
	EVENT_MAP = {
		:vcard	=>	State::Doctors::VCard,
	}
	def legal_note
		State::Doctors::LegalNote.new(@session, nil)
	end
	def limit_state
		State::Doctors::Limit.new(@session, nil)
	end
end
		end
	end
end
