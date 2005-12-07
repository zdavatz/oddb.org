#!/usr/bin/env ruby
# User -- oddb -- 15.11.2002 -- hwyss@ywesee.com 

require 'sbsm/user'
require 'util/persistence'
require 'model/invoice'
require 'model/invoice_observer'
require 'state/global_predefine'

module ODDB
	class User < SBSM::KnownUser
		include Persistence
		attr_accessor :model, :unique_email, :pass_hash
		HOME = State::Drugs::Init
		def init(app)
			@pointer.append(@oid)
		end
		def identified_by?(email, pass_hash) # email, hashed_password
			pass_hash == @pass_hash \
				&& email.to_s.downcase == @unique_email.to_s.downcase
		end
		def allowed?(obj)
			false
		end
		def ancestors(app=nil)
			[@model].compact
		end
		def cache_html?
			false
		end
		def creditable?(obj)
			false
		end
		def model=(model)
			model.user = self
			@model = model
		end
		def pointer_descr
			:set_pass
		end
		def valid?
			true
		end
		def viral_module
			self::class::VIRAL_MODULE
		end
		private
		def adjust_types(values, app)
			if((email = values[:unique_email]) \
				&& (other = app.user_by_email(email)))
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
		def allowed?(obj)
			[ODDB::IncompleteSequence, ODDB::IncompletePackage, 
				ODDB::IncompleteActiveAgent].include?(obj.class)
		end
		def cache_html?
			true
		end
		def creditable?(obj)
			false
		end
		def valid?
			false
		end
		def viral_module 
		end
	end
	class AdminUser < User
		SESSION_WEIGHT = 4
		VIRAL_MODULE = State::Admin::Root
		def allowed?(obj)
			case obj.odba_instance
			when Hospital
				@model.odba_instance == obj
			else
				true
			end
		end
		def creditable?(obj)
			true
		end
	end
	class RootUser < AdminUser
		def initialize
			@oid = 0
			@unique_email = 'hwyss@ywesee.com'
			@pass_hash = 'fc16bcd5a418882563a2fc2ec532639e'
			@pointer = Pointer.new([:user, 0])
		end
		def allowed?(obj)
			true
		end
	end		
	class CompanyUser < User
		SESSION_WEIGHT = 4
		VIRAL_MODULE = State::Admin::CompanyUser
		def allowed?(obj)
			case obj.odba_instance
			when ActiveAgent
				allowed?(obj.sequence)
			when Company
				@model.odba_instance == obj
			when Fachinfo
				allowed?(obj.registrations.first)
			when Package
				allowed?(obj.sequence)
			when Registration
				allowed?(obj.company)
			when Sequence
				allowed?(obj.registration)	
			end
		end
		def company_name
			@model ? @model.name : ''
		end
	end
	class PowerUser < User
		include InvoiceObserver
		SESSION_WEIGHT = 4
		VIRAL_MODULE = State::Admin::PowerUser
		def valid?
			self.invoices.any? { |invoice|
				invoice.payment_received? && !invoice.expired?
			}
		end
		def email
			@unique_email
		end
	end
	class PowerLinkUser < User
		VIRAL_MODULE = State::Admin::PowerLinkUser
	end
	module UserObserver
		attr_reader :user
		def contact_email
			@user.unique_email if(@user)
		end
		def has_user?
			!@user.nil?
		end
		def user=(user)
			@user = user
			self.odba_isolated_store
			@user
		end
	end
end
