#!/usr/bin/env ruby
# State::Drugs::Registration -- oddb -- 10.03.2003 -- hwyss@ywesee.com 

require 'state/drugs/global'
require 'state/drugs/sequence'
require 'state/drugs/selectindication'
require 'state/drugs/fachinfoconfirm'
require 'model/fachinfo'
require 'view/drugs/registration'

module ODDB
	module State
		module Drugs
class Registration < State::Drugs::Global
	VIEW = View::Drugs::RootRegistration
	PDF_DIR = File.expand_path('../../../doc/resources/fachinfo/', File.dirname(__FILE__))
	def new_sequence
		pointer = @session.user_input(:pointer)
		model = pointer.resolve(@session.app)
		seq_pointer = pointer + [:sequence]
		item = Persistence::CreateItem.new(seq_pointer)
		item.carry(:iksnr, model.iksnr)
		if (klass=resolve_state(seq_pointer))
			klass.new(@session, item)
		else
			self
		end
	end
	def update
		keys = [:inactive_date, :generic_type, :registration_date, :revision_date, :market_date]
		if(@model.is_a? Persistence::CreateItem)
			iksnr = @session.user_input(:iksnr)
			if(error_check_and_store(:iksnr, iksnr, [:iksnr]))
				return self
			else
				@model.append(iksnr)
			end
		end
		do_update(keys)
	end
	private
	def do_update(keys)
		new_state = self
		hash = user_input(keys)
		comp_name = @session.user_input(:company_name)
		if(company = @session.app.company_by_name(comp_name))
			hash.store(:company, company.oid)
		else
			err = create_error(:e_unknown_company, :company_name, comp_name)
			@errors.store(:company_name, err)
		end
		ind = user_input(:indication)
		sel = nil
		if(indication = @session.app.indication_by_text(ind))
			hash.store(:indication, indication.pointer)
		elsif(!ind.empty?)
			#err = create_error(:e_unknown_indication, :indication, ind)
			#@errors.store(:indication, err)
			input = hash.dup
			input.store(:indication, ind)
			sel = State::Drugs::SelectIndication::Selection.new(input, 
				@session.app.search_indications(ind), @model)
			new_state = State::Drugs::SelectIndication.new(@session, sel)
		end
		if(fi_file = @session.user_input(:fachinfo_upload)) 
			four_bytes = fi_file.read(4)
			fi_file.rewind
			if(four_bytes == "%PDF")
				filename = "#{@model.iksnr}.pdf"
				FileUtils.mkdir_p(self::class::PDF_DIR)
				path = File.expand_path(filename, self::class::PDF_DIR)
				File.open(path, "w") { |fh|
					fh.write(fi_file.read)
				}
				hash.store(:pdf_fachinfo, filename)
			elsif(documents = parse_fachinfo(fi_file))
				new_state = State::Drugs::FachinfoConfirm.new(@session, documents)
			else
				add_warning(:w_no_fachinfo_saved, :fachinfo_upload, nil)
			end
		end
		@model = @session.app.update(@model.pointer, hash)
		if(sel)
			sel.registration = @model
		end
		new_state
	end
	def parse_fachinfo(file)
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
end
class CompanyRegistration < State::Drugs::Registration
	def init
		super
		unless(allowed?)
			@default_view = View::Drugs::Registration
		end
	end
	def new_sequence
		if(allowed?)
			super
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
