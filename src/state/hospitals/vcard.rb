#!/usr/bin/env ruby
# State::Hospitals::Vcard -- oddb -- 09.03.2005 -- jlang@ywesee.com

require 'view/hospitals/vcard'

module ODDB
	module State
		module Hospitals
class VCard < Global
	VIEW = View::Hospitals::VCard
	VOLATILE = true
	LIMITED = true
	def init
		pointer = @session.user_input(:pointer)
		@model = pointer.resolve(@session)
		super
	end
end
		end
	end
end
