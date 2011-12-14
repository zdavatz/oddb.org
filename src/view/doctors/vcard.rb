#!/usr/bin/env ruby
# encoding: utf-8
# View::Doctors::Vcard -- oddb -- 10.11.2004 -- jlang@ywesee.com, usenguel@ywesee.com

require 'htmlgrid/component'
require 'view/vcard'

module ODDB
	module View
		module Doctors
class VCard < View::VCard
	def init
		@content = [:name, :title, :email, :addresses]
	end
	def get_filename
		filename = @model.name.sub(/\s/u, '_').to_s +
			"_" + @model.firstname.sub(/\s/u, '_').to_s + ".vcf"
	end
	def name
		if((firstname = @model.firstname) \
			&& (name = @model.name))
			[
				"FN;CHARSET=UTF-8:" + firstname + " " + name,
				"N;CHARSET=UTF-8:" + name + ";" + firstname,
			]
		end
	end
end
		end
	end
end
