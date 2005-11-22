#!/usr/bin/env ruby
# State::Hospitals::Global -- oddb -- 17.09.2004 --jlang@ywesee.com

require 'state/hospitals/init'
require 'state/hospitals/vcard'
require 'state/hospitals/limit'
require 'state/hospitals/hospitallist'

module ODDB
	module State
		module Hospitals
class Global < State::Global
	HOME_STATE = State::Hospitals::Init
	ZONE = :hospitals
	ZONE_NAVIGATION = [
		:help_link,
		:faq_link,
		State::Hospitals::HospitalList,
	]
	EVENT_MAP = {
		:vcard	=>	State::Hospitals::VCard,
	}
	def limit_state
		State::Hospitals::Limit.new(@session, nil)
	end
end
		end
	end
end
