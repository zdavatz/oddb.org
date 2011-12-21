#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::AddressSuggestion -- oddb.org -- 21.12.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Admin::AddressSuggestion -- oddb.org -- 09.08.2005 -- jlang@ywesee.com

require 'state/global_predefine'
require 'model/company'
require 'model/hospital'
require 'model/doctor'
require 'view/admin/address_suggestion'

module ODDB
	module State
		module Admin
class AddressSuggestion < Global
	VIEW = ODDB::View::Admin::AddressSuggestion
	attr_reader :active_address
	class AddressWrapper < SimpleDelegator
		attr_accessor :email_suggestion
	end
	def init
		if(addr = @model.address_instance or addr = @model.address_pointer.resolve(@session))
			@active_address = AddressWrapper.new(addr)
      @parent = if (ean_or_oid = @session.persistent_user_input(:ean) || @session.persistent_user_input(:oid)) \
                  and (parent = @session.search_doctor(ean_or_oid) || @session.search_doctors(ean_or_oid).first) 
                    parent
                elsif ean = @session.persistent_user_input(:ean) and  parent = @session.search_hospital(ean_or_oid)
                  parent
                else pointer = @model.address_pointer
                  pointer.parent.resolve(@session)
                end
			select_zone(@parent)
			@active_address.email_suggestion = @parent.email
		end
		super
	end
	def accept
		mandatory = [:name]
		keys = [:additional_lines, :address, :location,
			:fon, :fax, :title, :canton, 
			:email_suggestion, :address_type] + mandatory
		input = user_input(keys, mandatory)
		input[:fax] = input[:fax].to_s.split(/\s*,\s*/u)
		input[:fon] = input[:fon].to_s.split(/\s*,\s*/u)
		lns = input[:additional_lines].to_s
		input.store(:additional_lines, 
			lns.split(/[\n\r]+/u))
		input.store(:type, input.delete(:address_type))
    if !error? and (addr = @model.address_instance or addr = @model.address_pointer.resolve(@session))
      email = input.delete(:email_suggestion)
      parent_input = {
        :email	=>	email,
        :dummy_id => rand(2**20) # This is used in order to call object#odba_store forcibly in Persistence#issue_update
                                 # otherwise, Doctor#addresses may be not updated
      }
      @session.app.update(@model.pointer, input, unique_email)
      addr.replace_with(@model)
      addr_idx = if addr_pointer = @model.address_pointer and addr_match = addr_pointer.to_s.match(/address,(\d)\./) 
                   addr_match[1]
                 end
      @parent.addresses.odba_persistent = false # This is necessary to update Doctor@addresses in ODBA::Persistable
      if parent_addr = @parent.addresses[addr_idx.to_i]
        parent_addr.replace_with(addr)
      else # create a new address
        parent_addr = Address2.new
        parent_addr.replace_with(addr)
        parent_addr.pointer = @parent.pointer + [:address, addr_idx]
        @parent.addresses << parent_addr
      end
      @session.app.update(@parent.pointer, parent_input, unique_email)
      ## nur nötig wenn suggestion nicht gelöscht wird
      @active_address.email_suggestion = email
			self
		end
	end
	def delete
		if((pointer = @session.user_input(:pointer)) \
			&& pointer.is_a?(Persistence::Pointer))
			@session.app.delete(pointer)
			trigger(:addresses)
		end
	end
	def home_state
		case zone
		when :companies
			State::Companies::Init
		when :doctors
			State::Doctors::Init
		when :hospitals
			State::Hospitals::Init
		else
			super
		end
	end
	def zone
		@zone || super
	end
	def zone_navigation
		case zone
		when :companies
			State::Companies::Global::ZONE_NAVIGATION
		when :doctors
			State::Doctors::Global::ZONE_NAVIGATION
		when :hospitals
			State::Hospitals::Global::ZONE_NAVIGATION
		else
			State::Admin::Global::ZONE_NAVIGATION
		end
	end
	private
	def select_zone(parent)
		case parent
		when ODDB::Company
			@zone = :companies
		when ODDB::Doctor
			@zone = :doctors
		when ODDB::Hospital
			@zone = :hospitals
		else
			@zone = :admin
		end
	end
end
		end
	end
end
