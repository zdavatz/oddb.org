#!/usr/bin/env ruby
# State::Admin::CompanyUser -- oddb -- 23.07.2003 -- hwyss@ywesee.com 

require 'state/admin/user'

module ODDB
	module State
		module Admin
class State::Companies::Company < State::Companies::Global; end
class State::Companies::UserCompany < State::Companies::Company; end
class State::Drugs::Registration < State::Drugs::Global; end
class State::Companies::CompanyRegistration < State::Drugs::Registration; end
class State::Drugs::Sequence < State::Drugs::Global; end
class State::Drugs::CompanySequence < State::Drugs::Sequence; end
class State::Drugs::ActiveAgent < State::Drugs::Global; end
class State::Drugs::CompanyActiveAgent < State::Drugs::ActiveAgent; end
class State::Drugs::Package < State::Drugs::Global; end
class State::Drugs::CompanyPackage < State::Drugs::Package; end
class State::Drugs::SlEntry < State::Drugs::Global; end
class State::Drugs::CompanySlEntry < State::Drugs::SlEntry; end
module CompanyUser
	RESOLVE_STATES = {
		[ :registration ]							=>	State::Companies::CompanyRegistration,
		[ :registration, :sequence ]	=>	State::Drugs::CompanySequence,
		[ :registration,
			:sequence, :active_agent ]	=>	State::Drugs::CompanyActiveAgent,
		[ :registration,
			:sequence, :package ]				=>	State::Drugs::CompanyPackage,
		[ :registration, :sequence,
			:package, :sl_entry ]				=>	State::Drugs::CompanySlEntry,
	}	
	include State::Admin::User
	def resolve_state(pointer)
		if(@session.user_equiv?(pointer))
			UserCompany
		else
			super
		end
	end
	def new_registration
		pointer = Persistence::Pointer.new(:registration)
		item = Persistence::CreateItem.new(pointer)
		item.carry(:company_name, @session.user.model)
		State::Drugs::Registration.new(@session, item)
	end
	def user_navigation
		[
			State::Drugs::AtcChooser,
			State::Companies::CompanyList,
			State::Admin::Logout,
		]
	end
end
		end
	end
end
