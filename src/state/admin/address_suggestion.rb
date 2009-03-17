#!/usr/bin/env ruby
# State::Admin::AddressSuggestion -- oddb -- 09.08.2005 -- jlang@ywesee.com

require 'state/global_predefine'
require 'model/company'
require 'model/hospital'
require 'model/doctor'
require 'view/admin/address_suggestion'

module ODDB
	module State
		module Admin
class AddressSuggestion < Global
	VIEW = View::Admin::AddressSuggestion
	attr_reader :active_address
	class AddressWrapper < SimpleDelegator
		attr_accessor :email_suggestion
	end
	def init
		if(pointer = @model.address_pointer)
			addr = pointer.resolve(@session)
			if(addr.nil?)
				addr = Address2.new
				addr.pointer = pointer
			end
			@active_address = AddressWrapper.new(addr)
			parent = pointer.parent.resolve(@session)
			select_zone(parent)
			@active_address.email_suggestion = parent.email
		end
		super
	end
	def accept
		mandatory = [:name]
		keys = [:additional_lines, :address, :location,
			:fon, :fax, :title, :canton, :pointer,
			:email_suggestion, :address_type] + mandatory
		input = user_input(keys, mandatory)
		input[:fax] = input[:fax].to_s.split(/\s*,\s*/u)
		input[:fon] = input[:fon].to_s.split(/\s*,\s*/u)
		lns = input[:additional_lines].to_s
		input.store(:additional_lines, 
			lns.split(/[\n\r]+/u))
		input.store(:type, input.delete(:address_type))
		if(!error? && (pointer = input.delete(:pointer)) \
			&& (sugg = pointer.resolve(@session)) \
			&& (addr_pointer = sugg.address_pointer))
			addr = addr_pointer.resolve(@session)
      if(addr.nil?)
        addr = addr_pointer.creator.resolve(@session)
        @active_address = AddressWrapper.new(addr)
      end
      email = input.delete(:email_suggestion)
      parent_input = {
        :email	=>	email,
      }
      @session.app.update(pointer, input, unique_email)
      addr.replace_with(sugg)
      @session.app.update(addr_pointer.parent,
        parent_input, unique_email)
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
