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
		attr_accessor :model, :unique_email, :pass_hash, :reset_token, :reset_until
		HOME = State::Drugs::Init
		def init(app)
			@pointer.append(@oid)
		end
		def identified_by?(email, pass_hash) # email, hashed_password
			pass_hash == @pass_hash \
				&& email.to_s.downcase == @unique_email.to_s.downcase
		end
		def allowed?(obj, key=nil)
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
			model.odba_store
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
		def allowed?(obj, key=nil)
			[ODDB::IncompleteSequence, ODDB::IncompletePackage, 
				ODDB::IncompleteActiveAgent].include?(obj.class)
		end
		def cache_html?
			true
		end
		def creditable?(obj)
			false
		end
		def model
		end
		def valid?
			false
		end
		def viral_module 
		end
	end
	class AdminUser < User
		SESSION_WEIGHT = 4
		VIRAL_MODULE = State::Admin::Admin
		def allowed?(obj, key=nil)
			case obj.odba_instance
			when Hospital
				@model.odba_instance == obj
			when Registration, Sequence, Package, ActiveAgent, SlEntry
				true
			end
		end
		def creditable?(obj)
			true
		end
	end
	class RootUser < User
		SESSION_WEIGHT = 4
		VIRAL_MODULE = State::Admin::Root
		def initialize
			@oid = 0
			@unique_email = 'hwyss@ywesee.com'
			@pass_hash = 'fc16bcd5a418882563a2fc2ec532639e'
			@pointer = Pointer.new([:user, 0])
		end
		def allowed?(obj, key=nil)
			true
		end
		def creditable?(obj)
			true
		end
	end		
	class CompanyUser < User
		SESSION_WEIGHT = 4
		VIRAL_MODULE = State::Admin::CompanyUser
		def allowed?(obj, key=nil)
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
			@model.odba_instance ? @model.name : ''
		end
		def creditable?(obj)
			!@model.nil?
		end
	end
	class PowerUser < User
		include InvoiceObserver
		SESSION_WEIGHT = 4
		VIRAL_MODULE = State::Admin::PowerUser
		def email
			@unique_email
		end
		def valid?
			self.invoices.any? { |invoice|
				invoice.payment_received? && !invoice.expired?
			}
		end
    def paid_invoices
      self.invoices.select { |invoice|
        invoice.odba_instance && invoice.payment_received?
      }
    end
    alias :name_last :name
	end
	class PowerLinkUser < User
		VIRAL_MODULE = State::Admin::PowerLinkUser
		def allowed?(obj, key=nil)
			case obj.odba_instance
			when Registration, Sequence, Package, ActiveAgent, SlEntry
				true
			end
		end
	end
  class YusUser < User
    PREFERENCE_KEYS = [ :salutation, :name_first, :name_last, :address, 
      :city, :plz, :company_name, :business_area, :phone, 
      :poweruser_duration]
    PREFERENCE_KEYS.each { |key|
      define_method(key) {
        remote_call(:get_preference, key) 
      }
    }
    attr_reader :yus_session
    def initialize(yus_session)
      @yus_session = yus_session
    end
    def allowed?(action, key=nil)
 			result = case key.odba_instance
			when ActiveAgent
				allowed?(action, key.sequence)
			when Company
        allowed?(action, key.pointer.to_yus_privilege)
			when Fachinfo
				allowed?(action, key.registrations.first)
			when Package
				allowed?(action, key.sequence)
			when Registration
				allowed?(action, key.company)
			when Sequence
				allowed?(action, key.registration)	
      else
        remote_call(:allowed?, action, key)
			end
      result
    end
    def creditable?(obj)
      unless(obj.is_a?(String))
        klass = obj.class.to_s.split('::').last
        obj = "org.oddb.#{klass}"
      end
      allowed?('credit', obj)
    end
		def creditable?(obj)
			allowed?('credit')
		end
    def expired?
      !@yus_session.ping
    rescue RangeError, DRb::DRbConnError
      true
    end
    def fullname
      [name_first, name_last].join(' ')
    end
    def model
      if(id = remote_call(:get_preference, 'association'))
        ODBA.cache.fetch(id, self)
      end
    end
    def groups
      remote_call(:entities).reject { |entity| 
        /@/.match(entity.name) 
      }
    end
    def method_missing(method, *args, &block)
      remote_call(method, *args, &block) 
    end
    def name
      remote_call(:name)
    end
    alias :email :name
    alias :unique_email :name
    def remote_call(method, *args, &block)
      @yus_session.send(method, *args, &block)
    rescue RangeError, DRb::DRbError => e
      warn e
    end
    def set_preferences(values)
      (values.keys - PREFERENCE_KEYS).each { |key|
        values.delete(key)
      }
      remote_call(:set_preferences, values)
    end
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
