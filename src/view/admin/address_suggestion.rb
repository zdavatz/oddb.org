#!/usr/bin/env ruby
# View::Admin::AddressSuggestion -- oddb -- 09.08.2005 -- jlang@ywesee.com

require 'view/resulttemplate'
require 'view/address'
require 'htmlgrid/urllink'

module ODDB
	module View
		module Admin
class AddressSuggestionForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:address_type,
		[0,1]	=>	:title, 
		[0,2]	=>	:name, 
		[0,3]	=>	:additional_lines, 
		[0,4]	=>	:address, 
		[0,5]	=>	:location,
		[0,6]	=>	:canton,
		[0,7]	=>	:fon,
		[0,8]	=>	:fax,
		[0,9]	=>	:email_suggestion,
		[1,10]	=>	:submit,
		[1,10,1]	=>	:delete,
	}
	CSS_MAP = {
		[0,0,2,11]	=>	'list',	
		[0,3]	=> 'list top',
	}
	COMPONENT_CSS_MAP = {
		[0,0,2,10]	=>	'standard',	
	}
	EVENT = :accept
	LABELS = true
	LEGACY_INTERFACE = false
	SYMBOL_MAP = {
		:address_type				=> HtmlGrid::Select,
		:canton							=> HtmlGrid::Select,
	}
	def init
		super
		error_message
	end
	def additional_lines(model)
		area = HtmlGrid::Textarea.new(:additional_lines, 
			model, @session, self)
		area.label = true
		area.css_class = 'standard'
		area
	end
	def delete(model)
		button = HtmlGrid::Button.new(:delete,
			model, @session, self)
		button.set_attribute('onclick', 
			"this.form.event.value='delete'; this.form.submit();")
		button
	end
end
class AddressSuggestionInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'suggest_addr_sender',
		[0,1]	=>	:email,
		[0,2]	=>	:address_message,
		[1,2]	=>	:message,
	}
	LEGACY_INTERFACE = false
	LABELS = true
	SYMBOL_MAP = {
		:address_message => HtmlGrid::LabelText,
		:email					 => HtmlGrid::MailLink,
	}
	CSS_MAP = {
		[0,0]	=>	'subheading',
		[0,1,2,2]	=>	'list',
		[0,2,2]	=> 'list top', 
	}
	CSS_CLASS = 'component'
	COLSPAN_MAP = {
		[0,0]	=> 2,
	}
	def message(model)
		model.message.to_s.gsub("\n", '<br>')
	end
end
class ActiveAddress < View::SuggestedAddress
	COMPONENTS = {
		[0,0]	=> 'active_address',
		[1,0]	=> :parent_class,
	}
	CSS_CLASS = 'component'
	CSS_MAP = {
		[0,0]	=>	'subheading',
		[1,0]	=>	'subheading-bold',
	}
	YPOS = 1
	LEGACY_INTERFACE = false
	def parent_class(model)
		parent = model.pointer.parent.resolve(@session)
		@lookandfeel.lookup(parent.class)
	end
end
class AddressSuggestionComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	AddressSuggestionForm,
		[1,0]		=>	AddressSuggestionInnerComposite,
		[2,0]		=>	:address,
	}
	CSS_CLASS = 'component'
	CSS_MAP = {
		[0,0,3]	=>	'list top',
	}
	LEGACY_INTERFACE = false
	def address(model)
		if(addr = @session.state.active_address)
			ActiveAddress.new(addr, @session, self)
		end
	end
end
class AddressSuggestionOuterComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	'suggest_addr_title',
		[0,0,1]	=>	:fullname,
		[0,1]		=>	AddressSuggestionComposite,
	}
	CSS_MAP = {
		[0,0]	=> 'th',
	}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
end
class AddressSuggestion < PrivateTemplate
	CONTENT = AddressSuggestionOuterComposite
	SNAPBACK_EVENT = :addresses
end
		end
	end
end
