#!/usr/bin/env ruby
# State::Admin::Registration -- oddb -- 10.03.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'state/admin/sequence'
require 'state/admin/selectindication'
require 'state/admin/fachinfoconfirm'
require 'state/admin/assign_fachinfo'
require 'model/fachinfo'
require 'view/admin/registration'
require 'util/log'

module ODDB
	module State
		module Admin
module FachinfoMethods
	FI_FILE_DIR = File.expand_path('../../../doc/resources/fachinfo/', File.dirname(__FILE__))
	def assign_fachinfo
		if(@model.fachinfo)
			State::Admin::AssignFachinfo.new(@session, @model)
		end
	end	
	private
	def get_fachinfo
		new_state = self
		if((fi_file = @session.user_input(:fachinfo_upload)) \
			&& language = @session.user_input(:language_select)) 
			language = language.intern
			four_bytes = fi_file.read(4)
			fi_file.rewind
			mail_link = @session.lookandfeel.event_url(:resolve, {'pointer' => model.pointer})
			if(four_bytes == "%PDF")
				filename = "#{@model.iksnr}_#{language}.pdf"
				FileUtils.mkdir_p(self::class::FI_FILE_DIR)
				path = File.expand_path(filename, self::class::FI_FILE_DIR)
				File.open(path, "w") { |fh|
					fh.write(fi_file.read)
				}
				fi_file.rewind
				new_state = State::Admin::WaitForFachinfo.new(@session, @model)
				new_state.previous = self
				@session.app.async {
					@session.app.failsafe { 
						new_state.signal_done(parse_fachinfo_pdf(fi_file), 
							path, @model, "application/pdf", language, mail_link)
					}
				}
			else
				filename = "#{@model.iksnr}_#{language}.doc"
				FileUtils.mkdir_p(self::class::FI_FILE_DIR)
				path = File.expand_path(filename, self::class::FI_FILE_DIR)
				File.open(path, "w") { |fh|
					fh.write(fi_file.read)
				}
				fi_file.rewind
				new_state = State::Admin::WaitForFachinfo.new(@session, @model)
				new_state.previous = self
				@session.app.async {
					new_state.signal_done(parse_fachinfo_doc(fi_file), 
						path, @model, "application/msword", language, mail_link)
				}
			end
		end
		new_state
	end
	def parse_fachinfo_doc(file)
		begin
			# establish connection to fachinfo_parser
			parser = DRbObject.new(nil, FIPARSE_URI)
			result = parser.parse_fachinfo_doc(file.read)
			result
		rescue StandardError => e
			msg = [
				@session.lookandfeel.lookup(:fachinfo_upload),
				'(' << e.message << ')'
			].join(' ')
			err = create_error(:e_service_unavailable, :fachinfo_upload, msg)
			@errors.store(:fachinfo_upload, err)
			e
		end
	end
	def parse_fachinfo_pdf(file)
		begin
			# establish connection to fachinfo_parser
			parser = DRbObject.new(nil, FIPARSE_URI)
			result = parser.parse_fachinfo_pdf(file.read)
			result
		rescue StandardError => e
			msg = [
				@session.lookandfeel.lookup(:fachinfo_upload),
				'(' << e.message << ')'
			].join(' ')
			err = create_error(:e_pdf_not_parsed, :fachinfo_upload, msg)
			@errors.store(:fachinfo_upload, err)
			puts e.class
			puts e.message
			puts e.backtrace
			e
		end
	end
end
module RegistrationMethods
	include FachinfoMethods
	def do_update(keys)
		new_state = self
		hash = user_input(keys)
		if(@model.is_a?(Persistence::CreateItem) && error?)
			return new_state
		end
		resolve_company(hash)
		if(hash[:registration_date].nil? && hash[:revision_date].nil?)
			error = create_error('e_missing_reg_rev_date', 
				:registration_date, nil)
			@errors.store(:registration_date, error)
			error = create_error('e_missing_reg_rev_date', 
				:revision_date, nil)
			@errors.store(:revision_date, error)
		end
		ind = @session.user_input(:indication)
		sel = nil
		if(indication = @session.app.indication_by_text(ind))
			hash.store(:indication, indication.pointer)
		elsif(!ind.empty?)
			input = hash.dup
			input.store(:indication, ind)
			sel = SelectIndicationMethods::Selection.new(input, 
				@session.app.search_indications(ind), @model)
			new_state = self.class::SELECT_STATE.new(@session, sel)
		end
		new_state = get_fachinfo
		ODBA.transaction { 
			@model = @session.app.update(@model.pointer, hash, unique_email)
		}
		if(sel)
			sel.registration = @model
		end
		new_state
	end
	def new_sequence
		pointer = @session.user_input(:pointer)
		model = pointer.resolve(@session.app)
		seq_pointer = pointer + [:sequence]
		item = Persistence::CreateItem.new(seq_pointer)
		item.carry(:iksnr, model.iksnr)
		item.carry(:company, model.company)
		if (klass=resolve_state(seq_pointer))
			klass.new(@session, item)
		else
			self
		end
	end
	def resolve_company(hash)
		comp_name = @session.user_input(:company_name)
		if(company = @session.company_by_name(comp_name) || @model.company)
			hash.store(:company, company.oid)
		else
			err = create_error(:e_unknown_company, :company_name, comp_name)
			@errors.store(:company_name, err)
		end
	end
end
class Registration < State::Admin::Global
	VIEW = View::Admin::RootRegistration
	SELECT_STATE = State::Admin::SelectIndication
	include RegistrationMethods
	def update
		keys = [
			:inactive_date, :generic_type, :registration_date, 
			:revision_date, :market_date, :expiration_date, 
			:complementary_type, :export_flag
		]
		if(@model.is_a? Persistence::CreateItem)
			iksnr = @session.user_input(:iksnr)
			if(error_check_and_store(:iksnr, iksnr, [:iksnr]))
				return self
			elsif(@session.app.registration(iksnr))
				error = create_error('e_duplicate_iksnr', :iksnr, iksnr)
				@errors.store(:iksnr, error)
				return self
			else
				@model.append(iksnr)
			end
		end
		do_update(keys)
	end
end
class CompanyRegistration < State::Admin::Registration
	def init
		super
		unless(allowed?)
			@default_view = View::Admin::Registration
		end
	end
	def allowed?
		@session.user.allowed?(@model.company)
	end
	def new_sequence
		if(allowed?)
			super
		end
	end
	def resolve_company(hash)
		if(@model.is_a?(Persistence::CreateItem))
			hash.store(:company, @session.user.model.oid)
		end
	end
	def update
		if(allowed?)
			super
		end
	end
end
class ResellerRegistration < Global
	include FachinfoMethods
	VIEW = View::Admin::ResellerRegistration
	def update
		company = @model.company
		if(company.invoiceable?)
			get_fachinfo
		else
			err = create_error(:e_company_not_invoiceable, :pdf_patinfo, nil)
			newstate = resolve_state(company.pointer).new(@session, company)
			newstate.errors.store(:pdf_patinfo, err)
			newstate
		end
	end
end
		end
	end
end
