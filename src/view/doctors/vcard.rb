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
	def get_fons(fons, text_key)
		(fons || []).inject([]) { |inj, num|
			inj.push(text_key  + num.to_s)
			inj
		}
	end
	def addr_str(addr, text_key, div)
		text_key \
			+ [addr.street, addr.number].compact.join(' ') \
			+ div + addr.city + div*2 + addr.plz
	end
	def addresses
		@model.addresses.inject([]) { |inj, addr| 
			inj += get_fons(addr.fon, "TEL;WORK;VOICE:")
			inj += get_fons(addr.fax, "TEL;WORK;FAX:")
			type = (addr.type == :work) ? 'WORK' : 'POSTAL'
			inj.push(addr_str(addr, "ADR;#{type};CHARSET=ISO-8859-1:;;", ';'))
			inj.push(addr_str(addr, "LABEL;#{type};CHARSET=ISO-8859-1:;;", ' '))
			inj
		}
	end
end
		end
	end
end

