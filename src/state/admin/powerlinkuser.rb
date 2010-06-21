#!/usr/bin/env ruby
# State::Admin::PowerLinkUser -- oddb -- 07.12.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/registration'

module ODDB
	module State
		module Companies
class Company < Global; end
class UserCompany < Company; end
class PowerLinkCompany < UserCompany; end
		end
		module Admin
class DeductiblePackage < Global; end
module PowerLinkUser
	include User
	RESOLVE_STATES = {
		[ :company ]						=>	State::Companies::PowerLinkCompany,
		[ :fachinfo ]						=>	State::Drugs::RootFachinfo,
		[ :registration ]				=>	State::Admin::ResellerRegistration,
		[ :registration,
			:sequence ]						=>	State::Admin::ResellerSequence,
		[ :registration,
			:sequence, :package ]	=>	State::Admin::DeductiblePackage,
	}	
  def fipi_overview
    if((pointer = @session.user_input(:pointer)) \
      && (company = pointer.resolve(@session.app)))
      State::Companies::FiPiOverview.new(@session, company)
    end
  end
	def new_fachinfo
		if((pointer = @session.user_input(:pointer)) \
				&& (registration = pointer.resolve(@session)))
			_new_fachinfo(registration)
		end
	end
	def limited?
		false
	end
end
		end
	end
end
