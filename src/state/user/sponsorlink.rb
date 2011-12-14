#!/usr/bin/env ruby
# encoding: utf-8
# State::User::Sponsorlink -- oddb -- 18.10.2005 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/sponsorlink'

module ODDB
	module State
		module User
class SponsorLink < State::User::Global
	VIEW = View::User::SponsorLink
	VOLATILE = true
end
		end
	end
end
