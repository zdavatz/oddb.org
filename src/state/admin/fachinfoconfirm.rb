#!/usr/bin/env ruby
# State::Admin::FachinfoConfirm -- oddb -- 26.09.2003 -- rwaltert@ywesee.com

require 'state/admin/global'
require 'view/admin/fachinfoconfirm'
require 'view/drugs/fachinfo'

module ODDB
	module State
		module Admin
class FachinfoConfirm < State::Admin::Global
	attr_accessor :language
	VIEW = View::Admin::FachinfoConfirm
	def init
		super
		validate_iksnrs()
	end
	def back
		@previous.previous
	end
	def iksnrs(fi_document)
		iksnr_src = fi_document.iksnrs.to_s.gsub("'", '')
		if(iksnr_src && (iksnrs = iksnr_src.match(/[0-9]+(,\s*[0-9]+)*/)))
			iksnrs[0].split(/,\s*/).collect { |iksnr|
				sprintf('%05i', iksnr.to_i)
			}
		else
			[]
		end
	end
	def preview
		index = @session.user_input(:index)
		fi = @model[index.to_i]
		State::Drugs::FachinfoPreview.new(@session, fi)
	end
	def update
		#	keys = [:state_id]
		#	input = user_input(keys)
		validate_iksnrs()
		if(error?)
			self
		else
			pointer = if(old_fachinfo = replaceable_fachinfo)
				old_fachinfo.pointer
			else
				Persistence::Pointer.new(:fachinfo).creator
			end
			values = {}
			#input[:language_select].each { |idx, lang|
				#	if(lang.length == 2)
					values.store(@language, @model.at(0))
					#	end
					#	}
			if(values.empty?)
				add_warning(:w_no_fachinfo_saved, :fachinfo_upload, nil)
				return self
			end
			fachinfo = @session.app.update(pointer, values, unique_email)
			@valid_iksnrs.each { |iksnr|
				@session.app.replace_fachinfo(iksnr, fachinfo.pointer)
			}
			store_slate
			@previous.previous
		end
	end
	def replaceable_fachinfo
		@valid_iksnrs.each { |iksnr|
			#if no fachinfo exists for this registration
			if(fi = @session.registration(iksnr).fachinfo)
				iksnrs = fi.registrations.collect { |reg| 
					reg.iksnr 
				}
				if((iksnrs - @valid_iksnrs).empty?)
					return fi
				end
			end
		}
		nil
	end
	def store_slate
		if(@session.user.is_a?(RootUser))
			store_slate_item(Time.now, :processing)
		end
		store_slate_item(Time.now, :annual_fee)
	end
	def store_slate_item(time, type)
		slate_pointer = Persistence::Pointer.new([:slate, :fachinfo])
		@session.app.create(slate_pointer)
		reg = @model.registration
		item_pointer = slate_pointer + :item
		expiry_time = InvoiceItem.expiry_time(FI_UPLOAD_DURATION, time)
		unit = @session.lookandfeel.lookup("fi_upload_#{type}")
		values = {
			:data					=>	{:name => reg.name_base},
			:duration			=>	FI_UPLOAD_DURATION,
			:expiry_time	=>	expiry_time,
			:item_pointer =>	reg.pointer,
			:price				=>	FI_UPLOAD_PRICES[type],
			:text					=>	reg.iksnr,
			:time					=>	time,
			:type					=>	type,
			:unit					=>	unit,
			:user_pointer	=>	@session.user.pointer,
			:vat_rate			=>	VAT_RATE, 
		} 
		@session.app.update(item_pointer.creator, values, unique_email)
	end
	def validate_iksnrs
		@valid_iksnrs = [@model.registration.iksnr]
		@errors = {}
		all_iksnrs = @model.inject([]) { |array, fi_document|
			array | iksnrs(fi_document)
		}
		all_iksnrs.each { |iksnr|
			if(reg = @session.app.registration(iksnr))
				if(allowed?(reg))	
					@valid_iksnrs.push(iksnr)
				else
					add_warning(:w_access_denied_iksnr, :fachinfo_upload, iksnr)
				end
			else
				add_warning(:w_unknown_iksnr, :fachinfo_upload, iksnr)
			end
		}
		if(@valid_iksnrs.empty?)
			err = create_error(:e_no_valid_iksnrs, :iksnrs, all_iksnrs)
			@errors.store(:iksnrs, err)
		end
		@valid_iksnrs
	end
end
		end
	end
end
