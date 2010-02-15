#!/usr/bin/env ruby
# State::Admin::WaitForFachinfo -- oddb -- 10.03.2003 -- mwalder@ywesee.com rwaltert@ywesee.com

require 'state/admin/global'
require 'state/admin/fachinfoconfirm'
require 'view/admin/wait_for_fachinfo'
require 'model/fachinfo'
require 'util/log'

module ODDB
	module State
		module Admin
class WaitForFachinfo < State::Admin::Global
	class Model < Array
		attr_accessor :registration, :mime_type
		def structural_ancestors(app = nil)
			[@registration]
		end
		def pointer_descr
			:fachinfo
		end
	end
	attr_accessor :wait_counter
	VIEW = View::Admin::WaitForFachinfo
	def init
		super
		@wait = true
		@wait_counter = 0
	end
	def wait
		if(@wait)
			@wait_counter+= 1
			if(@wait_counter > 4)
				@wait_counter = 0
			end
			self
		elsif(@document)
			model = Model.new
			model.push(@document)
			model.registration = @model
      model.mime_type = @mime_type
			fi_confirm = State::Admin::FachinfoConfirm.new(@session, model)
			fi_confirm.language = @language
			fi_confirm
		else
			@previous	
		end
	end
	def signal_done(document, path, model, mimetype, language, link)
		if(document.is_a?(FachinfoDocument))
			@language = language
			@document = document
      @mime_type = mimetype
		else
      user = @session.user
			log = Log.new(Time.now)
			report = <<-EOS
Email: #{user.name}
Name:  #{user.name_first} #{user.name_last}
Link:  #{link}
      EOS
			if(document.is_a?(Exception))
				report = ([
					link, nil, document.class, document.message
				] + document.backtrace).join("\n")
			end
			log.report = report
			log.files = { 
				path => mimetype 
			}
      subject = "Fachinfo Parse Error Reg: #{model.iksnr}, Language; #{language}"
			log.notify subject, @session.user.name
		end
		@wait = false
	end
end
		end
	end
end
