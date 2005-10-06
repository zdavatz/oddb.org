#!/usr/bin/env ruby
# State::Companies::Company -- oddb -- 11.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'state/global_predefine'
require 'view/hospitals/hospital'
require 'model/hospital'

module ODDB
	module State
		module Hospitals
class Hospital < State::Hospitals::Global
	VIEW = View::Hospitals::Hospital
	LIMITED = true
end
class RootHospital < Hospital
	VIEW = View::Hospitals::RootHospital
	def do_update(keys)
		mandatory = [:name, :ean13]
		input = user_input(keys, mandatory)
		unless (error?)
			addr = @model.address(0)
			addr.type = input.delete(:address_type)
			addr.title = input.delete(:title)
			addr.name = input.delete(:contact)
			addr.additional_lines = input.delete(:additional_lines).to_s.split(/\r?\n/)
			addr.address = input.delete(:address)
			addr.location = input.delete(:location)
			addr.canton = input.delete(:canton)
			addr.fon = input.delete(:fon).to_s.split(/\s*,\s*/)
			addr.fax = input.delete(:fax).to_s.split(/\s*,\s*/)
			ODBA.transaction {
				@model = @session.app.update(@model.pointer, input)
			}
		end
		self
	end
	def set_pass
		update() # save user input
		unless(error?)
			State::Hospitals::SetPass.new(@session, user_or_creator)
		end
	end
	def update
		keys = [:name, :business_unit, :address_type, :title, :contact, 
			:additional_lines, :address, :location, :canton, :fon, :fax]
		do_update(keys)
	end
	def user_or_creator
		mdl = @model.user
		if(mdl.nil?)
			ptr = Persistence::Pointer.new([:admin])
			mdl = Persistence::CreateItem.new(ptr) 
			mdl.carry(:model, @model)
			#mdl.carry(:unique_email, @session.user_input(:contact_email))
		end
		mdl
	end
end
		end
	end
end
