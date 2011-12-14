#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::Admin -- ydim -- 01.03.2006 -- hwyss@ywesee.com

require 'state/admin/user'
require 'state/admin/logout'
require 'state/admin/init'
require 'state/hospitals/hospital'

module ODDB
	module State
		module Admin
class Global < State::Global; end
class ActiveAgent < Global; end
class Package < Global; end
class Registration < Global; end
class Sequence < Global; end
class SlEntry < Global; end
module Admin
	include State::Admin::User
	RESOLVE_STATES = {
		[ :hospital ]									=>	State::Hospitals::RootHospital,
		[ :registration ]							=>	State::Admin::Registration,
		[ :registration, :sequence ]	=>	State::Admin::Sequence,
		[ :registration,
			:sequence, :active_agent ]	=>	State::Admin::ActiveAgent,
		[ :registration,
			:sequence, :package ]				=>	State::Admin::Package,
		[ :registration, :sequence,
			:package, :sl_entry ]				=>	State::Admin::SlEntry,
	}	
	def limited?
		false
	end
	def new_registration
		pointer = Persistence::Pointer.new(:registration)
		item = Persistence::CreateItem.new(pointer)
		if(@model.is_a?(Company))
			item.carry(:company, @model)
			item.carry(:company_name, @model.name)
		end
    item.carry :sequences, {}
    item.carry :packages, []
		State::Admin::Registration.new(@session, item)
	end
	def zones
		[:analysis, :doctors, :interactions, :drugs, :migel, :user, :hospitals, :companies]
	end
end
		end
	end
end
