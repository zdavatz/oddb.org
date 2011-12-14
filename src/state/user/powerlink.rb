#!/usr/bin/env ruby
# encoding: utf-8
# State::User::PowerLink -- ODDB -- 21.10.2003 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/powerlink'

module ODDB
	module State
		module User
class PowerLink < State::User::Global
	VIEW = View::User::PowerLink
	VOLATILE = true
end
		end
	end
end
