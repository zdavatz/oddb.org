#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Hospitals::Vcard -- oddb.org -- 01.11.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Hospitals::Vcard -- oddb.org -- 09.03.2005 -- jlang@ywesee.com

require 'view/hospitals/vcard'

module ODDB
	module State
		module Hospitals
class VCard < Global
	VIEW = View::Hospitals::VCard
	VOLATILE = true
	LIMITED = true
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
