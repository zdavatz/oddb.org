#!/usr/bin/env ruby
# -- oddb -- 10.03.2005 -- jlang@ywesee.com

require 'htmlgrid/component'

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
			inj.push(addr_str(addr, "ADR;#{type};CHARSET=ISO-8859-1:;;", ';'))
			inj.push(addr_str(addr, "LABEL;#{type};CHARSET=ISO-8859-1:;;", ' '))
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
			"FN;CHARSET=ISO-8859-1:" + @model.name,
			"N;CHARSET=ISO-8859-1:" + @model.name,
		]
	end
	def title
		if(title = @model.title)
			["TITLE;CHARSET=ISO-8859-1:" + title]
		end
	end
	def prepare(str)
		str = str.dup
		str.gsub!(/[äÄæÆ]/, 'ae')
		str.gsub!(/[áÁàÀâÂãÃ]/, 'a')
		str.gsub!(/[çÇ]/, 'c')
		str.gsub!(/[ëËéÉèÈêÊ]/, 'e')
		str.gsub!(/[ïÏíÍìÌîÎ]/, 'i')
		str.gsub!(/[öÖ]/, 'oe')
		str.gsub!(/[óÓòÒôÔõÕøØ]/, 'o')
		str.gsub!(/[üÜ]/, 'ue')
		str.gsub!(/[úÚùÙûÛ]/, 'u')
		str.tr!('şßğ', 'psd')
		str
	end
end
	end
end
