#!/usr/bin/env ruby
# State::User::Checkout -- ODDB -- 18.04.2005 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/checkout'

module ODDB
	module State
		module User
class Checkout < State::User::Global
	VIEW = View::User::Checkout
end
		end
	end
end
