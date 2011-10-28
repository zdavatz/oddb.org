#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Doctors::Vcard -- oddb.org -- 28.10.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Doctors::Vcard -- oddb.org -- 10.11.2004 -- jlang@ywesee.com

require 'view/doctors/vcard'

module ODDB
	module State
		module Doctors
class VCard < Global
	VIEW = View::Doctors::VCard
	VOLATILE = true
	LIMITED = false
	def init
		if pointer = @session.user_input(:pointer)
		  @model = pointer.resolve(@session)
    end
		super
	end
end
		end
	end
end
