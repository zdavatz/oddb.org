#!/usr/bin/env ruby
# State::Admin::AddressSuggestion -- oddb -- 09.08.2005 -- jlang@ywesee.com

require 'state/global_predefine'
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
		if((pointer = @model.address_pointer) \
			&& (addr = pointer.resolve(@session)))
			@active_address = AddressWrapper.new(addr)
			parent = pointer.parent.resolve(@session)
			@active_address.email_suggestion = parent.email
		end
		super
	end
	def delete
		if((pointer = @session.user_input(:pointer)) \
			&& pointer.is_a?(Persistence::Pointer))
			@session.app.delete(pointer)
			trigger(:addresses)
		end
	end
	def accept
		mandatory = [:name]
		keys = [:additional_lines, :address, :location,
			:fon, :fax, :title, :canton, :pointer,
			:email_suggestion, :address_type] + mandatory
		input = user_input(keys, mandatory)
		input[:fax] = input[:fax].to_s.split(/\s*,\s*/)
		input[:fon] = input[:fon].to_s.split(/\s*,\s*/)
		lns = input[:additional_lines].to_s
		input.store(:additional_lines, 
			lns.split(/[\n\r]+/))
		input.store(:type, input.delete(:address_type))
		if(!error? && (pointer = input.delete(:pointer)) \
			&& (sugg = pointer.resolve(@session)) \
			&& (addr_pointer = sugg.address_pointer) \
			&& (addr = addr_pointer.resolve(@session)))
			ODBA.transaction {
				email = input.delete(:email_suggestion)
				parent_input = {
					:email	=>	email,
				}
				puts parent_input.inspect
				@session.app.update(pointer, input)
				addr.replace_with(sugg)
				@session.app.update(addr_pointer.parent, 
					parent_input)
				## nur nötig wenn suggestion nicht gelöscht wird
				@active_address.email_suggestion = email
				puts @active_address.inspect
			}
			self
		end
	end
end
		end
	end
end
