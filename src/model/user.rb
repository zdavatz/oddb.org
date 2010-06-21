#!/usr/bin/env ruby
# User -- oddb -- 15.11.2002 -- hwyss@ywesee.com 

require 'drb'
require 'sbsm/user'
require 'util/oddbconfig'
require 'util/persistence'
require 'model/invoice'
require 'model/invoice_observer'
require 'state/global_predefine'
require 'yus/entity'

module ODDB
	class UnknownUser < SBSM::UnknownUser
		HOME = State::Drugs::Init
    def allowed?(obj, key=nil)
      false
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
	end
  class YusStub
    YUS_SERVER = DRb::DRbObject.new(nil, YUS_URI)
    attr_reader :yus_name
    def initialize yus_name
      @yus_name = yus_name
    end
    alias :invoice_email :yus_name
    alias :contact_email :yus_name
    def method_missing key
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.get_entity_preference(@yus_name, key)
      }
    rescue Yus::YusError
      # user not found
    end
    def == other
      other.is_a?(YusStub) && @yus_name == other.yus_name
    end
    alias :eql? :==
  end
  class YusUser < SBSM::KnownUser
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
			when ActiveAgentCommon
				allowed?(action, key.sequence)
			when Company
        allowed?(action, key.pointer.to_yus_privilege)
			when Fachinfo
				allowed?(action, key.registrations.first)
			when PackageCommon
				allowed?(action, key.sequence)
			when RegistrationCommon
				allowed?(action, key.company) \
          || allowed?(action, key.pointer.to_yus_privilege)
			when SequenceCommon
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
    def expired?
      !@yus_session.ping
    rescue RangeError, DRb::DRbConnError, NoMethodError
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
        /@/u.match(entity.name)
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
    attr_writer :invoice_email
    def add_user user
      unless user.nil? || users.include?(user)
        users.push user
        users.odba_store
        odba_store
        user
      end
    end
    def contact_email
      if usr = users.first
        usr.yus_name
      end
    end
		def has_user?
      !users.empty?
		end
    def invoice_email
      @invoice_email || contact_email
    end
    def remove_user user
      if res = users.delete(user)
        users.odba_store
        odba_store
        res
      end
    end
    def users
      @users ||= [@user].compact
    end
	end
end
