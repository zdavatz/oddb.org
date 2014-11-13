#!/usr/bin/env ruby
# encoding: utf-8
# State::HC_providers::Global -- oddb -- 17.09.2004 --jlang@ywesee.com

require 'state/hc_providers/init'
require 'state/hc_providers/vcard'
require 'state/hc_providers/limit'
require 'state/hc_providers/hc_providerlist'

module ODDB
	module State
		module HC_providers
class Global < State::Global
	HOME_STATE = State::HC_providers::Init
	ZONE = :hc_providers
	ZONE_NAVIGATION = [
		State::HC_providers::HC_providerList,
	]
	EVENT_MAP = {
		:vcard	=>	State::HC_providers::VCard,
	}
	def limit_state
		State::HC_providers::Limit.new(@session, nil)
	end
end
		end
	end
end
