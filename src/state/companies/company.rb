#!/usr/bin/env ruby
# State::Companies::Company -- oddb -- 27.05.2003 -- maege@ywesee.com

require 'state/companies/global'
require 'state/companies/setpass'
require 'view/companies/company'
require 'model/company'
require 'fileutils'

module ODDB
	module State
		module Companies
class Company < State::Companies::Global
	VIEW = View::Companies::UnknownCompany
end
class UserCompany < State::Companies::Company
	VIEW = View::Companies::UserCompany
	LOGO_PATH = File.expand_path('../../doc/resources/logos',
		File.dirname(__FILE__))
	def set_pass
		update() # save user input
		mdl = @model.user
		if(mdl.nil?)
			mdl = Persistence::CreateItem.new(Persistence::Pointer.new([:user])) 
			mdl.carry(:model, @model)
			mdl.carry(:unique_email, @model.contact_email)
		end
		State::Companies::SetPass.new(@session, mdl)
	end
	def update
		unless(@session.user_equiv?(@model))
			#(@model.user == @session.user)
			return State::Companies::Company.new(@session, @model) 
		end
		keys = [
			:address,
			:address_email,
			:business_area,
			:contact,
			:contact_email,
			:ean13,
			:fax,
			:fi_status,
			:generic_type,
			:pi_status,
			:location,
			:logo_file,
			:name,
			:phone,
			:plz,
			:url,
		]
		do_update(keys)
	end
	private
	def do_update(keys)
		mandatory = [:name]
		input = user_input(keys, mandatory)
		if((upload = input[:logo_file]) && !upload.original_filename.empty?)
			if((fname = @model.logo_filename) \
				&& (old = File.expand_path(fname, LOGO_PATH)) \
				&& File.exist?(old))
				begin
					File.delete(old)
				rescue StandardError
					# ignore
				end
			end
			filename = @model.oid.to_s << "_" << upload.original_filename
			input[:logo_filename] = filename
			path = File.expand_path(filename, LOGO_PATH)
			begin
				FileUtils.mkdir_p(LOGO_PATH)
				File.open(path, 'wb') { |fh|
					fh << upload.read
				}
			rescue StandardError => e
				err = create_error(:e_exception, :logo_file, e.message)
				@errors.store(:logo_file, err)
			end
		end
		input.delete(:logo_file)
		unless (error?)
			company = @session.app.company_by_name(input[:name])
			unless(company.nil? || company==@model)
				@errors.store(:name, create_error('e_duplicate_company', :name, input[:name]))
			else
				ODBA.batch {
					@model = @session.app.update(@model.pointer, input)
				}
			end
		end
		self
	end
end
class RootCompany < State::Companies::UserCompany
	VIEW = View::Companies::RootCompany
	def delete
		if(@model.empty?)
			ODBA.batch {
				@session.app.delete(@model.pointer)
			}
			State::Companies::CompanyList.new(@session, @session.app.companies)
		else
			State::Companies::MergeCompanies.new(@session, @model)
		end
	end
	def update
		keys = [
			:address,
			:address_email,
			:business_area,
			:cl_status,
			:contact,
			:contact_email,
			:ean13,
			:fax,
			:fi_status,
			:generic_type,
			:pi_status,
			:location,
			:logo_file,
			:name,
			:phone,
			:plz,
			:powerlink,
			:regulatory_email,
			:url,
		]
		do_update(keys)
	end
end
		end
	end
end
