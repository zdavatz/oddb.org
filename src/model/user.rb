#!/usr/bin/env ruby
# User -- oddb -- 15.11.2002 -- hwyss@ywesee.com 

require 'sbsm/user'
require 'util/persistence'
require 'state/states'

module ODDB
	class CompanyListState < GlobalState; end
	class YweseeContactState < GlobalState; end
	class LogoutState < GlobalState; end
	class User < SBSM::KnownUser
		include Persistence
		attr_accessor :model, :unique_email, :pass_hash
		HOME = InitState
		def init(app)
			@pointer.append(@oid)
		end
		def identified_by?(*args) # email, hashed_password
			args == [@unique_email, @pass_hash]
		end
		def ancestors(app=nil)
			[@model].compact
		end
		def model=(model)
			model.user = self
			@model = model
		end
		def pointer_descr
			:set_pass
		end
		def viral_module
			self::class::VIRAL_MODULE
		end
		private
		def adjust_types(values, app)
			if(other = app.user_by_email(values[:unique_email]))
				raise 'e_duplicate_email' unless(other==self)
			end
			if((pointer = values[:model]).is_a?(Pointer))
				values[:model] = pointer.resolve(app)
			end
			super
		end
	end
	class UnknownUser < SBSM::UnknownUser
		HOME = InitState
		NAVIGATION = [
			AtcChooserState,
			CompanyListState,
			LoginState,
			YweseeContactState,
			InitState,
		]
	end
	class RootUser < User
		VIRAL_MODULE = RootState
		NAVIGATION = [
			SponsorState,
			CompanyListState,
			IndicationsState,
			GalenicGroupsState,
			IncompleteRegsState,
			LogoutState,
			InitState,
		]
		def initialize
			@oid = 0
			@unique_email = 'hwyss@ywesee.com'
			@pass_hash = 'fc16bcd5a418882563a2fc2ec532639e'
			@pointer = Pointer.new([:user, 0])
		end
	end		
	class CompanyUser < User
		VIRAL_MODULE = CompanyUserState
		NAVIGATION = [
			AtcChooserState,
			CompanyListState,
			LogoutState,
			InitState,
		]
	end
end
