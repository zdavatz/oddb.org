#!/usr/bin/env ruby
# RegistrationState -- oddb -- 10.03.2003 -- hwyss@ywesee.com 

require 'state/global'
require 'state/sequence'
require 'state/fachinfoconfirm'
require 'model/fachinfo'
require 'view/registration'

module ODDB
	class RegistrationState < GlobalState
		VIEW = RootRegistrationView
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
			hash = user_input(keys)
			comp_name = @session.user_input(:company_name)
			if(company = @session.app.company_by_name(comp_name))
				hash.store(:company, company.oid)
			else
				err = create_error(:e_unknown_company, :company_name, comp_name)
				@errors.store(:company_name, err)
			end
			ind = user_input(:indication)
			if(indication = @session.app.indication_by_text(ind))
				hash.store(:indication, indication.pointer)
			elsif(!ind.empty?)
				err = create_error(:e_unknown_indication, :indication, ind)
				@errors.store(:indication, err)
			end
			@model = @session.app.update(@model.pointer, hash)
			if((fi_file = @session.user_input(:fachinfo_upload)) \
				&& (documents = parse_fachinfo(fi_file)))
				FachinfoConfirmState.new(@session, documents)
			else
				self
			end
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
	class CompanyRegistrationState < RegistrationState
		def init
			super
			unless(@session.user_equiv?(@model.company))
				@default_view = RegistrationView
			end
		end
		def new_sequence
			if(@session.user_equiv?(@model.company))
				super
			end
		end
		def update
			if(@session.user_equiv?(@model.company))
				super
			end
		end
	end
end
