#!/usr/bin/env ruby
# State::Doctors::Vcard -- oddb -- 10.11.2004 -- jlang@ywesee.com

require 'view/doctors/vcard'

module ODDB
	module State
		module Doctors
class VCard < Global
	VIEW = View::Doctors::VCard
	VOLATILE = true
	def init
		pointer = @session.user_input(:pointer)
		@model = pointer.resolve(@session)
		super
	end
end
		end
	end
end
