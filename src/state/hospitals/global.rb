#!/usr/bin/env ruby
# State::Hospitals::Global -- oddb -- 17.09.2004 --jlang@ywesee.com

require 'state/hospitals/init'
require 'state/hospitals/vcard'
require 'state/legalnote'

module ODDB
	module State
		module Hospitals
class Global < State::Global
	HOME_STATE = State::Hospitals::Init
	ZONE = :hospitals
	EVENT_MAP = {
		:vcard	=>	State::Hospitals::VCard,
	}
	def zone_navigation
		[
			:help_link,
			:faq_link,
			#State::Hospitals::HospitalList,
		]
	end
	def legal_note
		State::Hospitals::LegalNote.new(@session, nil)
	end
end
		end
	end
end
