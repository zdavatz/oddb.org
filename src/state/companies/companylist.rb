#!/usr/bin/env ruby
# State::Companies::CompanyList -- oddb -- 26.05.2003 -- mhuggler@ywesee.com

require 'state/companies/global'
require 'state/companies/company'
require 'view/companies/companylist'
require 'model/company'
require 'model/user'
require 'util/interval'
require 'sbsm/user'

module ODDB
	module State
		module Companies
class CompanyResult < State::Companies::Global
	include Interval
	attr_reader :range
	DIRECT_EVENT = :search
	LIMITED = true
	VIEW = {
		ODDB::UnknownUser	=>	View::Companies::UnknownCompanies,
		ODDB::CompanyUser	=>	View::Companies::UnknownCompanies,
		ODDB::RootUser		=>	View::Companies::RootCompanies,
		ODDB::AdminUser		=>	View::Companies::RootCompanies,
	}	
	def init
		if(!@model.is_a?(Array) || @model.empty?)
			if(@session.user.is_a?(AdminUser))
				@default_view = View::Companies::RootEmptyResult
			else
				@default_view = View::Companies::EmptyResult
			end
		end
		filter_interval
	end
end
class CompanyList < CompanyResult
	DIRECT_EVENT = :companylist
	def init
		model = @session.app.companies.values
		if(@session.user.is_a?(ODDB::AdminUser))
			@model = model
		elsif(@session.user.is_a?(ODDB::CompanyUser))
			@model = model.select { |company|
				(company.listed? || @session.user_equiv?(company))
			}
		else
			@model = model.select { |company|
				company.listed?
			}
		end
		super
	end
end
		end
	end
end
