#!/usr/bin/env ruby
# State::Companies::MergeCompanies -- oddb -- 02.03.2011 -- mhatakeyama@ywesee.com
# State::Companies::MergeCompanies -- oddb -- 17.06.2003 -- mhuggler@ywesee.com

require 'state/companies/global'
require 'view/companies/mergecompanies'
require 'state/companies/company'

module ODDB
	module State
		module Companies
class MergeCompanies < State::Companies::Global
	VIEW = ODDB::View::Companies::MergeCompanies
	def merge
		company = @session.user_input(:company_form)
		target = @session.app.company_by_name(company)
		if(target.nil?)
			@errors.store(:company, create_error('e_unknown_company', :company, company))
			self
		elsif(target == @model)
			@errors.store(:company, create_error('e_selfmerge_company', :company, company))
			self
		else
			@session.app.merge_companies(@model.pointer, target.pointer)
			State::Companies::Company.new(@session, target)	
		end
	end
end
		end
	end
end
