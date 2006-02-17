#!/usr/bin/env ruby
# State::Admin::PowerLinkUser -- oddb -- 07.12.2005 -- hwyss@ywesee.com

require 'state/global_predefine'

module ODDB
	module State
		module Companies
class Company < Global; end
class PowerLinkCompany < Company; end
		end
		module Admin
class DeductiblePackage < Global; end
module PowerLinkUser
	include User
	RESOLVE_STATES = {
		[ :company ]						=>	State::Companies::PowerLinkCompany,
		[ :registration,
			:sequence, :package ]	=>	State::Admin::DeductiblePackage,
	}	
	def limited?
		false
	end
end
		end
	end
end
