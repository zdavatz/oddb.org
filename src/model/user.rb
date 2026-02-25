#!/usr/bin/env ruby

# User -- oddb -- 15.11.2002 -- hwyss@ywesee.com

require "sbsm/user"
require "util/oddbconfig"
require "util/persistence"
require "model/invoice"
require "model/invoice_observer"
require "state/global_predefine"

module ODDB
  class UnknownUser < SBSM::UnknownUser
    HOME = State::Drugs::Init
    def allowed?(obj, key = nil)
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

  class SwiyuStub
    attr_reader :yus_name
    def initialize(yus_name)
      @yus_name = yus_name
    end
    alias_method :invoice_email, :yus_name
    alias_method :contact_email, :yus_name

    def ==(other)
      other.is_a?(SwiyuStub) && @yus_name == other.yus_name
    end
    alias_method :eql?, :==
  end

  class SwiyuUser < SBSM::KnownUser
    attr_reader :gln, :first_name, :last_name, :roles_config

    PREFERENCE_KEYS = [:salutation, :name_first, :name_last, :address,
      :city, :plz, :company_name, :business_area, :phone,
      :poweruser_duration]

    def initialize(gln:, first_name:, last_name:, roles_config: nil)
      @gln = gln
      @first_name = first_name
      @last_name = last_name
      @roles_config = roles_config || {}
    end

    def allowed?(action, key = nil)
      return check_permission(action, key) if key.nil? || key.is_a?(String)
      resolved = key.respond_to?(:odba_instance) ? key.odba_instance : key
      case resolved
      when ActiveAgent
        allowed?(action, resolved.sequence)
      when InactiveAgent
        allowed?(action, resolved.sequence)
      when Company
        allowed?(action, resolved.pointer.to_yus_privilege)
      when Fachinfo
        allowed?(action, resolved.registrations.first)
      when PackageCommon
        allowed?(action, resolved.sequence)
      when RegistrationCommon
        allowed?(action, resolved.company) \
        || allowed?(action, resolved.pointer.to_yus_privilege)
      when SequenceCommon
        allowed?(action, resolved.registration)
      else
        check_permission(action, key)
      end
    end

    def valid?
      !@gln.nil? && !@gln.empty?
    end

    def expired?
      false
    end

    def name
      "#{@first_name} #{@last_name}"
    end

    def email
      @gln
    end
    alias_method :unique_email, :email

    def fullname
      "#{@first_name} #{@last_name}"
    end

    def model
      if (id = @roles_config&.dig("association"))
        ODBA.cache.fetch(id, self)
      end
    rescue ODBA::OdbaError
      nil
    end

    def creditable?(obj)
      unless obj.is_a?(String)
        klass = obj.class.to_s.split("::").last
        obj = "org.oddb.#{klass}"
      end
      allowed?("credit", obj)
    end

    def cache_html?
      false
    end

    def generate_token
      nil
    end

    def remove_token(_token)
      nil
    end

    def groups
      []
    end

    def set_preferences(_values)
    end

    def name_first
      @roles_config&.dig("preferences", "name_first") || @first_name
    end

    def name_last
      @roles_config&.dig("preferences", "name_last") || @last_name
    end

    PREFERENCE_KEYS.each do |key|
      next if method_defined?(key)
      define_method(key) do
        @roles_config&.dig("preferences", key.to_s)
      end
    end

    private

    def check_permission(action, key)
      return false unless @roles_config

      roles = @roles_config["roles"] || []

      # Root users have all permissions
      return true if roles.include?("org.oddb.RootUser")

      # Check role-level login permissions
      if action.to_s == "login"
        return roles.any? { |r| r == key.to_s }
      end

      # Check explicit permissions list
      permissions = @roles_config["permissions"] || []
      permissions.any? do |perm|
        perm["action"] == action.to_s &&
          (key.nil? || perm["key"] == key.to_s)
      end
    end
  end

  # Keep YusStub as alias for backward compatibility with persisted ODBA objects
  YusStub = SwiyuStub

  module UserObserver
    attr_writer :invoice_email
    def add_user(user)
      unless user.nil? || users.include?(user)
        users.push user
        users.odba_store
        odba_store
        user
      end
    end

    def contact_email
      if (usr = users.first)
        usr.yus_name
      end
    end

    def has_user?
      !users.empty?
    end

    def invoice_email
      @invoice_email || contact_email
    end

    def remove_user(user)
      if (res = users.delete(user))
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
