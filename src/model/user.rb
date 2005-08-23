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
		def identified_by?(*args) # email, hashed_password
			args == [@unique_email, @pass_hash]
		end
		def ancestors(app=nil)
			[@model].compact
		end
		def cache_html?
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
		def cache_html?
			true
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
end
