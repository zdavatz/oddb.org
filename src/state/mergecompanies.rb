#!/usr/bin/env ruby
# MergeCompaniesState -- oddb -- 17.06.2003 -- maege@ywesee.com

require 'state/global'
require 'view/mergecompanies'

module ODDB
	class MergeCompaniesState < GlobalState
		VIEW = MergeCompaniesView
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
				CompanyState.new(@session, target)	
			end
		end
	end
end
