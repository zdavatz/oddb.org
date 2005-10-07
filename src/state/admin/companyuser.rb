#!/usr/bin/env ruby
# State::Admin::CompanyUser -- oddb -- 23.07.2003 -- hwyss@ywesee.com 

require 'state/admin/user'
require 'state/companies/global'
require 'state/admin/patinfo_stats'

module ODDB
	module State
		module Companies
class Company < Global; end
class UserCompany < Company; end
		end
		module Drugs
class Fachinfo < Global; end
class RootFachinfo < Fachinfo; end
class CompanyFachinfo < RootFachinfo; end
		end
		module Admin
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
module CompanyUser
	include State::Admin::User
	RESOLVE_STATES = {
		[ :fachinfo ]									=>	State::Drugs::CompanyFachinfo,
		[ :registration ]							=>	State::Admin::CompanyRegistration,
		[ :registration, :sequence ]	=>	State::Admin::CompanySequence,
		[ :registration,
			:sequence, :active_agent ]	=>	State::Admin::CompanyActiveAgent,
		[ :registration,
			:sequence, :package ]				=>	State::Admin::CompanyPackage,
		[ :registration, :sequence,
			:package, :sl_entry ]				=>	State::Admin::CompanySlEntry,
	}	
	def home_companies
		klass = State::Companies::UserCompany
		if(self.is_a?(klass))
			State::Companies::Init.new(@session, nil)
		else
			klass.new(@session, @session.user.model)
		end
	end
	def limited?
		false
	end
	def resolve_state(pointer, type=:standard)
		if(@session.user_equiv?(pointer))
			State::Companies::UserCompany
		else
			super
		end
	end
	def new_registration
		pointer = Persistence::Pointer.new(:registration)
		item = Persistence::CreateItem.new(pointer)
		item.carry(:company, @session.user.model)
		item.carry(:company_name, @session.user.model.name)
		State::Admin::CompanyRegistration.new(@session, item)
	end
	def patinfo_stats
		State::Admin::PatinfoStatsCompanyUser.new(@session,[])
	end
	def patinfo_stats_company
		State::Admin::PatinfoStatsCompanyUser.new(@session,[])
	end
	def user_navigation
		[
			State::Admin::Logout,
		]
	end
	def zones
		[:admin, :interactions,:drugs, :migel, :user, :substances, :companies]
	end
end
		end
	end
end
