#!/usr/bin/env ruby
# View::Hospitals::Vcard -- oddb -- 09.03.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'htmlgrid/component'
require 'view/vcard'

module ODDB
	module View
		module Hospitals
class VCard < View::VCard
	def init
		@content = [:name, :address]
	end
	def get_filename
		filename = @model.name.sub(/\s/, '_').to_s + 
			"_" + @model.business_unit.sub(/\s/, '_').to_s + ".vcf"
	end
	def name
		if((firstname = @model.name) \
			&& (name = @model.business_unit))
			[
				"FN;CHARSET=ISO-8859-1:" + firstname + " " + name,
				"N;CHARSET=ISO-8859-1:" + name + ";" + firstname,
			]
		end
	end
	def address
		addr_parts = [
			@model.address, @model.location, nil, @model.plz	
		]
		[
			"TEL;WORK;VOICE: #{@model.phone}",
			"TEL;WORK;FAX: #{@model.fax}",
		  "ADR;#WORK;CHARSET=ISO-8859-1:;;#{addr_parts.join(';')}",
			"LABEL;WORK;CHARSET=ISO-8859-1:;;#{addr_parts.compact.join(' ')}",
		]
	end
end
		end
	end
end

