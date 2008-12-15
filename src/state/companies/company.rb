#!/usr/bin/env ruby
# State::Companies::Company -- oddb -- 27.05.2003 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/companies/setpass'
require 'view/companies/company'
require 'model/company'
require 'fileutils'

module ODDB
	module State
		module Companies
class Company < Global
	VIEW = View::Companies::UnknownCompany
	LIMITED = true
	def snapback_event
		@model.name
	end
end
class UserCompany < Company
	VIEW = View::Companies::UserCompany
	LOGO_PATH = File.expand_path('../../../doc/resources/logos',
		File.dirname(__FILE__))
	def set_pass
		update() # save user input
		if(allowed? && !error?)
			State::Companies::SetPass.new(@session, user_or_creator)
		end
	end
	def update
		unless(@session.allowed?('edit', @model.pointer.to_yus_privilege))
			return State::Companies::Company.new(@session, @model) 
		end
		keys = [
			:address,
			:address_email,
			:business_area,
			:complementary_type,
			:contact,
			:contact_email,
			:ean13,
			:fax,
			:fi_status,
			:generic_type,
			:pi_status,
			:city,
			:logo_file,
			:name,
			:phone,
			:plz,
			:regulatory_email,
			:url,
		]
		do_update(keys)
	end
	private
	def do_update(keys, mandatory=[:name])
		input = user_input(keys, mandatory)
		if((upload = input.delete(:logo_file)) \
			&& !upload.original_filename.empty?)
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
		unless (error?)
			contact_email = input.delete(:contact_email)
      company = nil
      if(name = input[:name])
        company = @session.app.company_by_name(name)
      end
			company ||= @model
			unless(company.nil? || company==@model)
				@errors.store(:name, create_error('e_duplicate_company', :name, input[:name]))
			else
				if((date = input[:invoice_date_patinfo]) \
					 && date != company.invoice_date(:patinfo) && date <= @@today)
					input.delete(:invoice_date_patinfo)
					err = create_error('e_date_must_be_in_future', :invoice_date_patinfo, 
						(@@today + 1).strftime('%d.%m.%Y'))
					@errors.store(:invoice_date_patinfo, err)
				end
				addr = nil
				if(@model.is_a?(Persistence::CreateItem))
					addr = Address2.new
					@model.carry(:addresses, [addr])
				else
					addr = @model.address(0) || @model.create_address
				end
				addr.address = input.delete(:address)
				addr.location = [
					input.delete(:plz),
					input.delete(:city),
				].compact.join(' ')
				addr.fon = input.delete(:fon).to_s.split(/\s*,\s*/)
				addr.fax = input.delete(:fax).to_s.split(/\s*,\s*/)
        @model = @session.app.update(@model.pointer, input, unique_email)
			end
		end
		self
	end
	def user_or_creator
		mdl = @model.user
		if(mdl.nil?)
			mdl = Persistence::CreateItem.new(Persistence::Pointer.new([:user])) 
			mdl.carry(:model, @model)
			mdl.carry(:unique_email, @session.user_input(:contact_email))
		end
		mdl
	end
end
class RootCompany < UserCompany
	VIEW = View::Companies::RootCompany
	def ajax
		ba = @session.user_input(:business_area)
		if(@model.is_a?(Persistence::CreateItem))
			@model.carry(:business_area, ba)
		else
			@session.app.update(@model.pointer, {:business_area => ba}, unique_email)
		end
		AjaxCompany.new(@session, @model)
	end
	def delete
		if(@model.empty?)
      @session.app.delete(@model.pointer)
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
			:city,
			:cl_status,
			:competition_email,
			:complementary_type,
			:contact,
			:contact_email,
			:disable_invoice_fachinfo,
			:disable_invoice_patinfo,
			:disable_patinfo,
			:ean13,
			:fax,
			:fon,
			:generic_type,
			:invoice_date_fachinfo,
			:invoice_date_index,
			:invoice_date_lookandfeel,
			:invoice_date_patinfo,
			:invoice_htmlinfos,
      :limit_invoice_duration,
			:logo_file,
			:lookandfeel_member_count,
			:name,
      :price_fachinfo,
			:price_index,
			:price_index_package,
			:price_lookandfeel,
			:price_lookandfeel_member,
			:price_patinfo,
			:plz,
			:powerlink,
			:regulatory_email,
      :swissmedic_email,
      :swissmedic_salutation,
			:url,
		]
		do_update(keys)
	end
end
class PowerLinkCompany < UserCompany
	VIEW = View::Companies::PowerLinkCompany
	def update
		mandatory = [
			:address,
			:city,
			:contact,
			:plz,
		]
		keys = mandatory + [
      :deductible_display,
			:fon,
			:powerlink,
		]
		do_update(keys, mandatory)
		self
	end
end
class AjaxCompany < Global
	VOLATILE = true
	def init
		@default_view = View::Companies::RootCompany.select_company_content(@model)
		super
	end
end
		end
	end
end
