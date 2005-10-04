#!/usr/bin/env ruby
# State::Admin::Sequence -- oddb -- 11.03.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/admin/sequence'
require 'model/sequence'
require 'state/admin/package'
require 'state/admin/activeagent'
require 'state/admin/assign_deprived_sequence'
require 'fileutils'
require 'net/smtp'
require 'tmail'

module ODDB
	module State
		module Admin
class Sequence < State::Admin::Global
	RECIPIENTS = []
	VIEW = View::Admin::RootSequence
	PDF_DIR = File.expand_path('../../../doc/resources/patinfo/', File.dirname(__FILE__))
	def assign_patinfo
		State::Admin::AssignDeprivedSequence.new(@session, @model)
	end	
	def atc_request
		if((company = @model.company) && (addr = company.regulatory_email))
			lookandfeel = @session.lookandfeel
			mail = TMail::Mail.new
			mail.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
			mail.to = [addr]
			mail.from = MAIL_FROM
			mail.subject = "#{@model.name_base} #{@model.iksnr}"
			mail.date = Time.now
			mail.body = [
				lookandfeel.lookup(:atc_request_email),
				lookandfeel.lookup(:name) + ": " + @model.name_base,
				lookandfeel.lookup(:registration) + ": " + @model.iksnr,
				lookandfeel.lookup(:package) + ": " \
					+ @model.packages.keys.join(","),
				lookandfeel._event_url(:resolve, {:pointer => @model.pointer}),
				nil, 
				lookandfeel.lookup(:thanks_for_cooperation),
			].join("\n")
			mail['User-Agent'] = 'ODDB Download'
			Net::SMTP.start(SMTP_SERVER) { |smtp|
				smtp.sendmail(mail.encoded, SMTP_FROM, [addr] + RECIPIENTS)
			}
			@model.atc_request_time = Time.now
			@model.odba_isolated_store
		end
		self
	end
	def delete
		registration = @model.parent(@session.app) 
		ODBA.batch {
			@session.app.delete(@model.pointer)
		}
		State::Admin::Registration.new(@session, registration)
	end
	def new_active_agent
		pointer = @session.user_input(:pointer)
		model = pointer.resolve(@session.app)
		aa_pointer = pointer + [:active_agent]
		item = Persistence::CreateItem.new(aa_pointer)
		item.carry(:iksnr, model.iksnr)
		item.carry(:name_base, model.name_base)
		item.carry(:sequence, model)
		if (klass=resolve_state(aa_pointer))
			klass.new(@session, item)
		else
			self
		end
	end
	def new_package
		pointer = @session.user_input(:pointer)
		model = pointer.resolve(@session.app)
		p_pointer = pointer + [:package]
		item = Persistence::CreateItem.new(p_pointer)
		item.carry(:iksnr, model.iksnr)
		item.carry(:name_base, model.name_base)
		item.carry(:sequence, model)
		if (klass=resolve_state(p_pointer))
			klass.new(@session, item)
		else
			self
		end
	end
	def update
		if(@model.is_a? Persistence::CreateItem)
			seqnr = @session.user_input(:seqnr)
			error =	if(seqnr.is_a? RuntimeError)
				seqnr
			elsif(seqnr.empty?)
				create_error(:e_missing_seqnr, :seqnr, seqnr)
			elsif(@model.parent(@session.app).sequence(seqnr))
				create_error(:e_duplicate_seqnr, :seqnr, seqnr)
			end
			if error
				@errors.store(:seqnr, error)
				return self
			end
			@model.append(seqnr)
		end
		keys = [
			:dose,
			:name_base, 
			:name_descr,
		]
		input = user_input(keys)
		galform = @session.user_input(:galenic_form)
		if(@session.app.galenic_form(galform))
			input.store(:galenic_form, galform)
		else
			err = create_error(:e_unknown_galenic_form, 
				:galenic_form, galform)
			@errors.store(:galenic_form, err)
		end
		atc_input = self.user_input(:code, :code)
		atc_code = atc_input[:code]
		if(atc_code.nil?)
			# error already stored by user_input(:code, :code)
		elsif((descr = @session.user_input(:atc_descr)) \
			&& !descr.empty?)
			pointer = Persistence::Pointer.new([:atc_class, atc_code])
			values = {
				@session.language	=> descr,	
			}
			@session.app.update(pointer.creator, values)
			input.store(:atc_class, atc_code)
		elsif(@session.app.atc_class(atc_code))
			input.store(:atc_class, atc_code)
		else
			@errors.store(:atc_class, create_error(:e_unknown_atc_class, :code, atc_code))
		end
		if(pi_file = @session.user_input(:patinfo_upload))
			if(pi_file.read(4) == "%PDF")
				pi_file.rewind
				filename = "#{@model.iksnr}_#{@model.seqnr}.pdf"
				FileUtils.mkdir_p(self::class::PDF_DIR)
				store_file = File.new(File.expand_path(filename, 
					self::class::PDF_DIR), "w")
				store_file.write(pi_file.read)
				store_file.close
				@model.pdf_patinfo = filename
				store_slate()
				input.store(:pdf_patinfo, filename)
			else
				add_warning(:w_no_patinfo_saved, :patinfo_upload, nil)
			end
		elsif(@session.user_input(:patinfo) == 'delete')
			input.store(:patinfo, nil)
			input.store(:pdf_patinfo, nil)
		end
		if((company = @model.company) \
			&& (mail = user_input(:regulatory_email)) && !mail.empty?)
			@session.app.update(company.pointer, mail)
		end
		ODBA.transaction {
			@model = @session.app.update(@model.pointer, input)
		}
		self
	end
	private
	def store_slate
		time = Time.now
		ODBA.transaction { 
			store_slate_item(time, :annual_fee)
			store_slate_item(time, :processing)
		}
	end
	def store_slate_item(time, type)
		slate_pointer = Persistence::Pointer.new([:slate, :patinfo])
		@session.app.create(slate_pointer)
		item_pointer = slate_pointer + :item
		expiry_time = InvoiceItem.expiry_time(PI_UPLOAD_DURATION, time)
		unit = @session.lookandfeel.lookup("pi_upload_#{type}")
		text = sprintf("%s %s", @model.iksnr, @model.seqnr)
		values = {
			:data					=>	{:name => @model.name},
			:duration			=>	PI_UPLOAD_DURATION,
			:expiry_time	=>	expiry_time,
			:item_pointer =>	@model.pointer,
			:price				=>	PI_UPLOAD_PRICES[type],
			:text					=>	text,
			:time					=>	time,
			:type					=>	type,
			:unit					=>	unit,
			:user_pointer	=>	@session.user.pointer,
			:vat_rate			=>	VAT_RATE, 
		} 
		@session.app.update(item_pointer.creator, values)
	end
end
class CompanySequence < State::Admin::Sequence
	def init
		super
		unless(allowed?)
			@default_view = View::Admin::Sequence 
		end
	end
	def delete
		if(allowed?)
			super
		end
	end
	def new_active_agent
		if(allowed?)
			super
		end
	end
	def new_package
		if(allowed?)
			super
		end
	end
	def update
		if(allowed?)
			super
		end
	end
	def store_slate
		store_slate_item(Time.now, :annual_fee)
	end
end
		end
	end
end
