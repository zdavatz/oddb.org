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
	DIRECT_EVENT = :result
	LIMITED = true
	def init
    priv = @session.user.allowed?('edit', 'org.oddb.model.!company.*')
    @default_view = priv ? View::Companies::RootCompanies \
                         : View::Companies::UnknownCompanies
		if(!@model.is_a?(Array) || @model.empty?)
      @default_view = priv ? View::Companies::RootEmptyResult \
                           : View::Companies::EmptyResult
		end
		filter_interval
	end
end
class CompanyList < CompanyResult
	DIRECT_EVENT = :companylist
	def init
		model = @session.app.companies.values
		if(@session.event != :listed_companies \
       && @session.user.allowed?('edit', 'org.oddb.model.!company.*'))
			@model = model
    else
      @direct_event = :listed_companies
      association = @session.user.model
			@model = model.select { |company|
				company.listed? || company == association
			}
		end
		super
	end
  def direct_event
    @direct_event || super
  end
end
		end
	end
end
