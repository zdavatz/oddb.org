#!/usr/bin/env ruby
# CompanyUserState -- oddb -- 23.07.2003 -- hwyss@ywesee.com 

require 'state/user'

module ODDB
	class CompanyState < GlobalState; end
	class UserCompanyState < CompanyState; end
	class RegistrationState < GlobalState; end
	class CompanyRegistrationState < RegistrationState; end
	class SequenceState < GlobalState; end
	class CompanySequenceState < SequenceState; end
	class ActiveAgentState < GlobalState; end
	class CompanyActiveAgentState < ActiveAgentState; end
	class PackageState < GlobalState; end
	class CompanyPackageState < PackageState; end
	class SlEntryState < GlobalState; end
	class CompanySlEntryState < SlEntryState; end
	module CompanyUserState
		RESOLVE_STATES = {
			[ :registration ]							=>	CompanyRegistrationState,
			[ :registration, :sequence ]	=>	CompanySequenceState,
			[ :registration,
				:sequence, :active_agent ]	=>	CompanyActiveAgentState,
			[ :registration,
				:sequence, :package ]				=>	CompanyPackageState,
			[ :registration, :sequence,
				:package, :sl_entry ]				=>	CompanySlEntryState,
		}	
		include UserState
		def resolve_state(pointer)
			if(@session.user_equiv?(pointer))
				UserCompanyState
			else
				super
			end
		end
		def new_registration
			pointer = Persistence::Pointer.new(:registration)
			item = Persistence::CreateItem.new(pointer)
			item.carry(:company_name, @session.user.model)
			RegistrationState.new(@session, item)
		end
	end
end
