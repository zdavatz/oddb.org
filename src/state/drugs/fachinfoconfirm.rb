#!/usr/bin/env ruby
# State::Drugs::FachinfoConfirm -- oddb -- 26.09.2003 -- rwaltert@ywesee.com

require 'state/drugs/global'
require 'state/drugs/fachinfo'
require 'view/drugs/fachinfoconfirm'

module ODDB
	module State
		module Drugs
class FachinfoConfirm < State::Drugs::Global
	VIEW = View::Drugs::FachinfoConfirm
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
		keys = [:language_select, :state_id]
		input = user_input(keys, [:language_select])
		validate_iksnrs()
		if(error?)
			self
		else

			
			pointer = Persistence::Pointer.new(:fachinfo)
			values = {}
			language = ''
			input[:language_select].each { |idx, lang|
				if(lang.length == 2)
					language = lang
					values.store(lang, @model.at(idx.to_i))
					puts values.inspect
				end
			}
			if(values.empty?)
				add_warning(:w_no_fachinfo_saved, :fachinfo_upload, nil)
				return self
			end
			old_fachinfo = @session.app.registration(@valid_iksnrs.first).fachinfo
			old_fachinfo.descriptions.each { |lang, fi|
				if(lang != language)
					values.store(lang, fi)
				end
			}
			fachinfo = @session.app.update(pointer.creator, values)
=begin
			regs = old_fachinfo.registrations
			regs.each{ |reg|
				if(@valid_iksnr.include?(reg.iksnr))
					@session.app.replace_fachinfo(iksnr, fachinfo.pointer)
				end
			}
=end
			@valid_iksnrs.each { |iksnr|
				@session.app.replace_fachinfo(iksnr, fachinfo.pointer)
			}
			@previous.previous
		end
	end
	def validate_iksnrs
		@valid_iksnrs = []
		@errors = {}
		all_iksnrs = @model.inject([]) { |array, fi_document|
			array | iksnrs(fi_document)
		}
		all_iksnrs.each { |iksnr|
			if(reg = @session.app.registration(iksnr))
				if(@session.user_equiv?(reg.company))	
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
