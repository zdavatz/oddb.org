#!/usr/bin/env ruby
# User -- oddb -- 15.11.2002 -- hwyss@ywesee.com 

require 'sbsm/user'
require 'util/persistence'
require 'state/global_predefine'

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
	module UserOid
		def set_oid
			User.instance_eval <<-EOS unless(User.respond_to?(:next_oid))
				@oid = nil
				class << self
					def next_oid
						# Persistence.current_oid(self).next # will break many tests,
						# but might solve the problem of mysterious reseting of oids
						@oid = (@oid || Persistence.current_oid(self)).next
					end
				end
			EOS
			@oid ||= User.next_oid
		end
	end
	class UnknownUser < SBSM::UnknownUser
		HOME = State::Drugs::Init
	end
	class AdminUser < User
		SESSION_WEIGHT = 4
		VIRAL_MODULE = State::Admin::Root
		include UserOid
	end
	class RootUser < AdminUser
		def initialize
			@oid = 0
			@unique_email = 'hwyss@ywesee.com'
			@pass_hash = 'fc16bcd5a418882563a2fc2ec532639e'
			@pointer = Pointer.new([:user, 0])
		end
	end		
	class CompanyUser < User
		SESSION_WEIGHT = 4
		VIRAL_MODULE = State::Admin::CompanyUser
		include UserOid
	end
end
