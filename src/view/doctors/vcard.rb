#!/usr/bin/env ruby
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
		filename = @model.name.sub(/\s/, '_').to_s + 
			"_" + @model.firstname.sub(/\s/, '_').to_s + ".vcf"
	end
	def name
		if((firstname = @model.firstname) \
			&& (name = @model.name))
			[
				"FN;CHARSET=ISO-8859-1:" + firstname + " " + name,
				"N;CHARSET=ISO-8859-1:" + name + ";" + firstname,
			]
		end
	end
end
		end
	end
end
