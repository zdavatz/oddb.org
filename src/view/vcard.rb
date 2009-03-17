#!/usr/bin/env ruby
# -- oddb -- 10.03.2005 -- jlang@ywesee.com

require 'htmlgrid/component'
require 'util/searchterms'

module ODDB
	module View
class VCard < HtmlGrid::Component
	def init
		@content = [:addresses]
	end
	def addresses
		@model.addresses.inject([]) { |inj, addr| 
			inj += get_fons(addr.fon, "TEL;WORK;VOICE:")
			inj += get_fons(addr.fax, "TEL;WORK;FAX:")
			type = (addr.type == :work) ? 'WORK' : 'POSTAL'
			inj.push(addr_str(addr, "ADR;#{type};CHARSET=UTF-8:;;", ';'))
			inj.push(addr_str(addr, "LABEL;#{type};CHARSET=UTF-8:;;", ' '))
			inj
		}
	end
	def addr_str(addr, text_key, div)
		text_key \
			+ [addr.street, addr.number].compact.join(' ') \
			+ div + addr.city + div*2 + addr.plz
	end
	def http_headers
		filename = get_filename
		filename = prepare(filename)
		{
			'Content-Type'	=>	'text/x-vCard',	
			'Content-Disposition'	=>	"attachment; filename=#{filename}",
		}
	end
	def email
		if(email = @model.email)
			["EMAIL;TYPE=internet:" + email]
		end
	end
	def to_html(context)
		vcard = [
			"BEGIN:vCard",
			"VERSION:3.0",
		]
		@content.each { |key|
			vcard += get_value(key)
		}
		vcard.push("END:vCard")
		vcard.join("\n")
	end
	def get_value(key)
		self.send(key) || []
	end
	def get_fons(fons, text_key)
		(fons || []).inject([]) { |inj, num|
			inj.push(text_key  + num.to_s)
			inj
		}
	end
	def name
		[
			"FN;CHARSET=UTF-8:" + @model.name,
			"N;CHARSET=UTF-8:" + @model.name,
		]
	end
	def title
		if(title = @model.title)
			["TITLE;CHARSET=UTF-8:" + title]
		end
	end
	def prepare(str)
    ODDB.search_term(str)
	end
end
	end
end
