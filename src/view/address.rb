#!/usr/bin/env ruby
# View::Address -- oddb -- 05.08.2005 -- jlang@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/urllink'

module ODDB
	module View
module AddressMap
	def map(address)
		link = HtmlGrid::Link.new(:map, address, @session, self)
		link.href = [
			'http://map.search.ch', 
			mapsearch_format(address.plz, address.city),
			mapsearch_format(address.street, address.number),
		].join('/')
		link.css_class = 'list'
		link
	end
	def mapsearch_format(*args)
		args.compact.join('-').gsub(/\s+/, '-')
	end		
end
module VCardMethods
	def vcard(model)
		link = HtmlGrid::Link.new(:vcard, model, @session, self)
		args = {:pointer => model.pointer}
		link.href = @lookandfeel.event_url(:vcard, args)
		link.css_class = 'list'
		link
	end
end
class SuggestedAddress < HtmlGrid::Composite
	include AddressMap
	COMPONENTS = {
		[1,0]	=>	:address_message,	
		[1,1]	=>	:message,	
	}
	SYMBOL_MAP = {
		:address_email	=>	HtmlGrid::MailLink,
		:email_suggestion	=>	HtmlGrid::MailLink,
		:address_message=>	HtmlGrid::LabelText,
		:praxis_header	=>	HtmlGrid::LabelText,
		:contact_email	=>	HtmlGrid::MailLink,
		:contact_header	=>	HtmlGrid::LabelText,
		:email_header		=>	HtmlGrid::LabelText,
		:fax_header			=>	HtmlGrid::LabelText,
		:fons_header		=>	HtmlGrid::LabelText,
		:nbsp						=>	HtmlGrid::Text,
		:phone_label		=>	HtmlGrid::Text,
		:work_header		=>	HtmlGrid::LabelText,
	}	
	CSS_MAP = {
		[1,0]	=>	'list',
		[1,1]	=>	'top',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	YPOS = 0
	CSS_CLASS = 'component'
	def init
		init_components unless(@model.nil?)
		super
	end
	def init_components
		ypos = ystart = self.class.const_get(:YPOS)
		components.update({
			[0,ypos]			=>	:type,
			[0,ypos + 1]	=>	:lines,
			[0,ypos + 2]	=>	:map,
			[0,ypos + 3]	=>	:fons_header,
			[0,ypos + 4]	=>	:fons,
		})
		ypos += 5
		unless(@model.fax.to_s.strip.empty?)
			components.update({
				[0,ypos]		 =>	:fax_header,
				[0,ypos + 1] =>	:fax,
			})
			ypos += 2
		end
		if(@model.respond_to?(:email_suggestion))
			components.update({
				[0,ypos]			=> :email_header,
				[0,ypos + 1]	=> :email_suggestion,
			})
			ypos += 2
		end
		css_map.store([0,ystart,1,ypos],	
			'top address-width list')
	end
	def correct(model)
		button = HtmlGrid::Button.new(:correct, 
			model, @session, self)
		args = {
			:pointer	=>	model.pointer,
			:zone			=>	@session.zone,
		}
		url = @lookandfeel._event_url(:suggest_address, args)
		button.set_attribute('onclick', 
			"document.location.href='#{url}'")
		button
	end
	def fax(model)
		model.fax.join('<br>')
	end
	def fons(model)
		model.fon.join('<br>')
	end
	def lines(model)
		model.lines.join('<br>')
	end
	def type(model)
		HtmlGrid::LabelText.new("address_#{model.type}", model, @session, self)
	end
	def message(model)
		model.message.to_s.gsub("\n", '<br>')
	end
end
class Address < SuggestedAddress
	COMPONENTS = {}
	def init_components
		super
		if(@model.respond_to?(:pointer))
			ypos = components.size
			components.store([0,ypos], :correct)
			css_map.store([0,ypos], 'top address-width list')
		end
	end
end
	end
end
