#!/usr/bin/env ruby
# View::Doctors::Vcard -- oddb -- 10.11.2004 -- jlang@ywesee.com, usenguel@ywesee.com

require 'htmlgrid/component'

module ODDB
	module View
		module Doctors 
class VCard < HtmlGrid::Component
	def http_headers
		filename = @model.name.to_s + ".vcf"
		{
			'Content-Type'	=>	'text/x-vCard',	
			'Content-Disposition'	=>	"attachment; filename=#{filename}",
		}
	end
	def to_html(context)
		vcard = [
			"BEGIN:vCard",
			"VERSION:3.0",
		]
		[:name, :title, :email, :addresses].each { |key|
			vcard += get_value(key)
		}
		vcard.push("END:vCard")
		vcard.join("\n")
	end
	def get_value(key)
		self.send(key) || []
	end
	def title
		if(title = @model.title)
			["TITLE:" + title]
		end
	end
	def name
		if((firstname = @model.firstname) \
			&& (name = @model.name))
			[
				"FN:" + firstname + " " + name,
				"N:" + name + ";" + firstname,
			]
		end
	end
	def email
		if(email = @model.email)
			["EMAIL;TYPE=internet:" + email]
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
			inj.push(addr_str(addr, "ADR;#{type}:;;", ';'))
			inj.push(addr_str(addr, "LABEL;#{type}:;;", ' '))
			inj
		}
	end
end
		end
	end
end

