#!/usr/bin/env ruby
# State::User::MeddrugsUpdate -- oddb -- 11.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/user/meddrugs_update'

module ODDB
	module State
		module User
class MeddrugsUpdate < Global
	VOLATILE = true
	VIEW = View::User::MeddrugsUpdate
end
		end
	end
end
