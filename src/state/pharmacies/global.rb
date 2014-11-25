#!/usr/bin/env ruby
# encoding: utf-8
# State::Pharmacies::Global -- oddb -- 17.09.2004 --jlang@ywesee.com

require 'state/pharmacies/init'
require 'state/pharmacies/vcard'
require 'state/pharmacies/limit'
require 'state/pharmacies/pharmacylist'

module ODDB
	module State
		module Pharmacies
class Global < State::Global
	HOME_STATE = State::Pharmacies::Init
	ZONE = :pharmacies
	ZONE_NAVIGATION = [
		State::Pharmacies::PharmacyList,
	]
	EVENT_MAP = {
		:vcard	=>	State::Pharmacies::VCard,
	}
	def limit_state
		State::Pharmacies::Limit.new(@session, nil)
	end
end
		end
	end
end
