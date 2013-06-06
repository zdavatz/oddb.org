#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::PatinfoPdfMethods -- oddb.org -- 06.06.2013 -- yasaka@ywesee.com

require 'drb/drb'
require 'state/admin/global'
require 'fileutils'

module ODDB
	module State
		module Admin
module PatinfoPdfMethods # for sequence, package
	PDF_DIR = File.expand_path('../../../doc/resources/patinfo/', File.dirname(__FILE__))
  HTML_PARSER = DRbObject.new(nil, FIPARSE_URI)
	def get_patinfo_input(input)
		newstate = self
    if((html_file = @session.user_input(:html_upload)) \
       && (document = parse_patinfo(html_file.read)) \
       && !self.is_a?(ODDB::State::Admin::Package)) # only sequence
      @model.pdf_patinfo = nil
      lang = @session.user_input(:language_select)
      ptr = nil
      if(patinfo = @model.patinfo)
        ptr = patinfo.pointer
      else
        ptr = Persistence::Pointer.new(:patinfo).creator
      end
      patinfo = @session.app.update(ptr, lang => document)
      input.store(:patinfo, patinfo.pointer)
      input.store(:pdf_patinfo, nil)
      @infos.push(:i_patinfo_assigned)
		elsif(pi_file = @session.user_input(:patinfo_upload))
			company = @model.company
			if(!company.invoiceable?)
				err = create_error(:e_company_not_invoiceable, :pdf_patinfo, nil)
				newstate = resolve_state(company.pointer).new(@session, company)
				newstate.errors.store(:pdf_patinfo, err)
			elsif(pi_file.read(4) == "%PDF")
        pi_file.rewind
        filename = if self.is_a?(ODDB::State::Admin::Package)
				  "#{@model.iksnr}_#{@model.seqnr}_#{@model.ikscd}_#{Time.now.to_f}.pdf"
        else
				  "#{@model.iksnr}_#{@model.seqnr}_#{Time.now.to_f}.pdf"
        end
				FileUtils.mkdir_p(self::class::PDF_DIR)
				store_file = File.new(File.expand_path(filename, self::class::PDF_DIR), "w")
				store_file.write(pi_file.read)
				store_file.close
				@model.pdf_patinfo = filename
				store_slate()
				input.store(:pdf_patinfo, filename)
			  input.store(:patinfo, nil) unless self.is_a?(ODDB::State::Admin::Package)
        unless self.is_a?(ODDB::State::Admin::Package)
				  newstate = State::Admin::AssignPatinfo.new(@session, @model)
        end
			else
				add_warning(:w_no_patinfo_saved, :patinfo_upload, nil)
			end
		elsif(@session.user_input(:patinfo) == 'delete')
			input.store(:patinfo, nil) unless self.is_a?(ODDB::State::Admin::Package)
			input.store(:pdf_patinfo, nil)
		end
		newstate
	end
  def parse_patinfo(src)
    HTML_PARSER.parse_patinfo_html(src)
  rescue StandardError => e
    msg = ' (' << e.message << ')'
    err = create_error(:e_html_not_parsed, :html_upload, msg)
    @errors.store(:html_upload, err)
    nil
  end
	def store_slate
		store_slate_item(Time.now, :annual_fee)
	end
	def store_slate_item(time, type)
		slate_pointer = Persistence::Pointer.new([:slate, :patinfo])
		@session.app.create(slate_pointer)
		item_pointer = slate_pointer + :item
		expiry_time = InvoiceItem.expiry_time(PI_UPLOAD_DURATION, time)
		unit = @session.lookandfeel.lookup("pi_upload_#{type}")
    text = if self.is_a?(ODDB::State::Admin::Package)
		  sprintf("%s %s %s", @model.iksnr, @model.seqnr, @model.ikscd)
    else
		  sprintf("%s %s", @model.iksnr, @model.seqnr)
    end
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
			:yus_name   	=>	@session.user.name,
			:vat_rate			=>	VAT_RATE, 
		} 
		@session.app.update(item_pointer.creator, values, unique_email)
	end
end
    end
  end
end
