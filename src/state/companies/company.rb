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
	LOGO_PATH = File.expand_path('../../doc/resources/logos',
		File.dirname(__FILE__))
	def set_pass
		update() # save user input
		if(allowed? && !error?)
			State::Companies::SetPass.new(@session, user_or_creator)
		end
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
			:complementary_type,
			:contact,
			:contact_email,
			:ean13,
			:fax,
			:fi_status,
			:generic_type,
			:invoice_email,
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
	def do_update(keys)
		mandatory = [:name]
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
			company = @session.app.company_by_name(input[:name])
			unless(company.nil? || company==@model)
				@errors.store(:name, create_error('e_duplicate_company', :name, input[:name]))
			else
				if((date = input[:pref_invoice_date]) \
					 && date != company.pref_invoice_date && date <= Date.today)
					input.delete(:pref_invoice_date)
					err = create_error('e_date_must_be_in_future', :pref_invoice_date, 
						(Date.today + 1).strftime('%d.%m.%Y'))
					@errors.store(:pref_invoice_date, err)
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
				ODBA.transaction {
					@model = @session.app.update(@model.pointer, input)
				}
				update_company_user(contact_email)
			end
		end
		self
	end
	def update_company_user(contact_email)
		if(contact_email && !contact_email.empty?)
			ODBA.transaction {
				user = user_or_creator
				args = {
					:unique_email => contact_email, 
					:model => @model
				}
				@session.app.update(user.pointer, args)
			}
		end
	rescue RuntimeError => e
		err = create_error(e.message, :unique_email, contact_email)
		@errors.store(:unique_email, err)
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
			@session.app.update(@model.pointer, {:business_area => ba})
		end
		AjaxCompany.new(@session, @model)
	end
	def delete
		if(@model.empty?)
			ODBA.transaction {
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
			:city,
			:cl_status,
			:complementary_type,
			:contact,
			:contact_email,
			:disable_autoinvoice,
			:ean13,
			:fax,
			:generic_type,
			:index_invoice_date,
			:index_package_price,
			:index_price,
			:invoice_email,
			:logo_file,
			:lookandfeel_invoice_date,
			:lookandfeel_member_count,
			:lookandfeel_member_price,
			:lookandfeel_price,
			:name,
			:patinfo_price,
			:phone,
			:plz,
			:powerlink,
			:pref_invoice_date,
			:regulatory_email,
			:url,
		]
		do_update(keys)
	end
end
class PowerLinkCompany < Company
	VIEW = View::Companies::PowerLinkCompany
	def update
		keys = [:powerlink]
		input = user_input(keys)
		ODBA.transaction {
			@model = @session.app.update(@model.pointer, input)
		}
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
