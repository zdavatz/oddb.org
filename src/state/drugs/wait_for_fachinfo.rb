#!/usr/bin/env ruby
# State::Drugs::WaitForFachinfo -- oddb -- 10.03.2003 -- mwalder@ywesee.com rwaltert@ywesee.com

require 'state/drugs/global'
require 'state/drugs/fachinfoconfirm'
require 'view/drugs/wait_for_fachinfo'
require 'util/log'

module ODDB
	module State
		module Drugs
class WaitForFachinfo < State::Drugs::Global
	class Model < Array
		attr_accessor :registration
		def ancestors(app = nil)
			[@registration]
		end
		def pointer_descr
			:fachinfo
		end
	end
	attr_accessor :wait_counter
	VIEW = View::Drugs::WaitForFachinfo
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
			State::Drugs::FachinfoConfirm.new(@session, model)
		else
			@previous	
		end
	end
	def signal_done(document, path, iksnr, mimetype)
		if(document)
			@document = document
		else
			log = Log.new(Time.now)
			log.files = { 
				path => mimetype 
			}
			log.notify("Fachinfo Parse Error Reg: #{iksnr}")
		end
		@wait = false
	end
end
		end
	end
end
