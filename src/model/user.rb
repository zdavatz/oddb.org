#!/usr/bin/env ruby
# User -- oddb -- 15.11.2002 -- hwyss@ywesee.com 

require 'sbsm/user'
require 'util/persistence'
require 'state/global_predefine'
#require 'state/states'
#require 'state/drugs/init'
#require 'state/admin/root'
#require 'state/admin/companyuser'
#require 'state/admin/user'

module ODDB
	class User < SBSM::KnownUser
		include Persistence
		attr_accessor :model, :unique_email, :pass_hash
		HOME = State::Drugs::Init
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
		HOME = State::Drugs::Init
	end
	class RootUser < User
		VIRAL_MODULE = State::Admin::Root
		def initialize
			@oid = 0
			@unique_email = 'hwyss@ywesee.com'
			@pass_hash = 'fc16bcd5a418882563a2fc2ec532639e'
			@pointer = Pointer.new([:user, 0])
		end
	end		
	class CompanyUser < User
		VIRAL_MODULE = State::Admin::CompanyUser
	end
end
