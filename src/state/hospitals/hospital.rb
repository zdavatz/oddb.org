#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Companies::Company -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Companies::Company -- oddb.org -- 11.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'state/global_predefine'
require 'view/hospitals/hospital'
require 'model/hospital'

module ODDB
	module State
		module Hospitals
class Hospital < State::Hospitals::Global
	VIEW = ODDB::View::Hospitals::Hospital
	LIMITED = true
end
class RootHospital < Hospital
	def init
		super
		if(allowed?)
			@default_view = ODDB::View::Hospitals::RootHospital
		end
	end
	def set_pass
		if(allowed?)
			do_update
			unless(error?)
				State::Hospitals::SetPass.new(@session, user_or_creator)
			end
		end
	end
	def update
		if(allowed?)
			do_update
		end
		self
	end
	private
	def do_update
		keys = [:name, :business_unit, :address_type, :title, :contact, 
			:additional_lines, :address, :location, :canton, :fon, :fax]
		mandatory = [:name, :ean13]
		input = user_input(keys, mandatory)
		unless (error?)
			addr = @model.address(0)
			addr.type = input.delete(:address_type)
			addr.title = input.delete(:title)
			addr.name = input.delete(:contact)
			addr.additional_lines = input.delete(:additional_lines).to_s.split(/\r?\n/u)
			addr.address = input.delete(:address)
			addr.location = input.delete(:location)
			addr.canton = input.delete(:canton)
			addr.fon = input.delete(:fon).to_s.split(/\s*,\s*/u)
			addr.fax = input.delete(:fax).to_s.split(/\s*,\s*/u)
      @model = @session.app.update(@model.pointer, input, unique_email)
		end
	end
	def user_or_creator
		mdl = @model.user
		if(mdl.nil?)
			ptr = Persistence::Pointer.new([:admin])
			mdl = Persistence::CreateItem.new(ptr) 
			mdl.carry(:model, @model)
		end
		mdl
	end
end
		end
	end
end
