#!/usr/bin/env ruby
# State::Admin::CompanyUser -- oddb -- 23.07.2003 -- hwyss@ywesee.com 

require 'state/admin/user'
require 'state/companies/global'
require 'state/drugs/global'

module ODDB
	module State
		module Companies
class Company < Global; end
class UserCompany < Company; end
		end
		module Drugs
class Registration < Global; end
class CompanyRegistration < Registration; end
class Sequence < Global; end
class CompanySequence < Sequence; end
class ActiveAgent < Global; end
class CompanyActiveAgent < ActiveAgent; end
class Package < Global; end
class CompanyPackage < Package; end
class SlEntry < Global; end
class CompanySlEntry < SlEntry; end
		end
		module Admin
module CompanyUser
	RESOLVE_STATES = {
		[ :registration ]							=>	State::Drugs::CompanyRegistration,
		[ :registration, :sequence ]	=>	State::Drugs::CompanySequence,
		[ :registration,
			:sequence, :active_agent ]	=>	State::Drugs::CompanyActiveAgent,
		[ :registration,
			:sequence, :package ]				=>	State::Drugs::CompanyPackage,
		[ :registration, :sequence,
			:package, :sl_entry ]				=>	State::Drugs::CompanySlEntry,
	}	
	include State::Admin::User
	def resolve_state(pointer)
		if(@session.user_equiv?(pointer))
			UserCompany
		else
			super
		end
	end
	def new_registration
		pointer = Persistence::Pointer.new(:registration)
		item = Persistence::CreateItem.new(pointer)
		item.carry(:company_name, @session.user.model)
		State::Drugs::Registration.new(@session, item)
	end
	def user_navigation
		[
			State::Drugs::AtcChooser,
			State::Companies::CompanyList,
			State::Admin::Logout,
		]
	end
end
		end
	end
end
