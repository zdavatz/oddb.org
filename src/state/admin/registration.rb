#!/usr/bin/env ruby
# State::Admin::Registration -- oddb -- 10.03.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'state/admin/sequence'
require 'state/admin/selectindication'
require 'state/admin/fachinfoconfirm'
require 'model/fachinfo'
require 'view/admin/registration'
require 'util/log'

module ODDB
	module State
		module Admin
class Registration < State::Admin::Global
	VIEW = View::Admin::RootRegistration
	FI_FILE_DIR = File.expand_path('../../../doc/resources/fachinfo/', File.dirname(__FILE__))
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
	def update
		keys = [
			:inactive_date, :generic_type, :registration_date, 
			:revision_date, :market_date, :expiration_date,
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
	private
	def resolve_company(hash)
		comp_name = @session.user_input(:company_name)
		if(company = @session.company_by_name(comp_name) || @model.company)
			hash.store(:company, company.oid)
		else
			err = create_error(:e_unknown_company, :company_name, comp_name)
			@errors.store(:company_name, err)
		end
	end
	def do_update(keys)
		new_state = self
		hash = user_input(keys)
		resolve_company(hash)
		if(@model.is_a?(Persistence::CreateItem) && error?)
			return self
		end
		language = user_input(:language_select).intern
		ind = user_input(:indication)
		sel = nil
		if(indication = @session.app.indication_by_text(ind))
			hash.store(:indication, indication.pointer)
		elsif(!ind.empty?)
			#err = create_error(:e_unknown_indication, :indication, ind)
			#@errors.store(:indication, err)
			input = hash.dup
			input.store(:indication, ind)
			sel = State::Admin::SelectIndication::Selection.new(input, 
				@session.app.search_indications(ind), @model)
			new_state = State::Admin::SelectIndication.new(@session, sel)
		end
		if(fi_file = @session.user_input(:fachinfo_upload)) 
			four_bytes = fi_file.read(4)
			fi_file.rewind
			if(four_bytes == "%PDF")
				filename = "#{@model.iksnr}_#{language}.pdf"
				FileUtils.mkdir_p(self::class::FI_FILE_DIR)
				path = File.expand_path(filename, self::class::FI_FILE_DIR)
				File.open(path, "w") { |fh|
					fh.write(fi_file.read)
				}
				fi_file.rewind
				if(pdf_fachinfos = @model.pdf_fachinfos)
					pdf_fachinfos.store(language, filename)
				else
					pdf_fachinfos = {language => filename}
				end
				hash.store(:pdf_fachinfos, pdf_fachinfos)
				new_state = State::Admin::WaitForFachinfo.new(@session, @model)
				new_state.previous = self
				@session.app.async {
					pdf_document =  parse_fachinfo_pdf(fi_file)
					new_state.signal_done(pdf_document, path, @model.iksnr, "application/pdf", language)
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
					word_document = parse_fachinfo_doc(fi_file)
					new_state.signal_done(word_document, path, @model.iksnr, "application/msword", language)
				}
			end
		end
		ODBA.batch { 
			@model = @session.app.update(@model.pointer, hash)
		}
		if(sel)
			sel.registration = @model
		end
		new_state
	end
	def parse_fachinfo_doc(file)
		begin
			# establish connection to fachinfo_parser
			#DRb.start_service
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
			nil
		end
	end
	def parse_fachinfo_pdf(file)
		begin
			# establish connection to fachinfo_parser
			#DRb.start_service
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
			nil
		end
	end
end
class CompanyRegistration < State::Admin::Registration
	def init
		super
		unless(allowed?)
			@default_view = View::Admin::Registration
		end
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
	def allowed?
		@session.user_equiv?(@model.company)
	end
end
		end
	end
end
