#!/usr/bin/env ruby
# View::SuggestAddress-- oddb -- 05.08.2005 -- jlang@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/select'
require 'htmlgrid/textarea'
require 'htmlgrid/errormessage'
require 'view/privatetemplate'
require 'view/form'

module ODDB
	module View
class SuggestAddressForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:address_type,
		[3,1]	=>	'suggest_addr_email',
		[0,1]	=>	:title, 
		[2,2]	=>	:email,
		[0,2]	=>	:name, 
		[0,3]	=>	:additional_lines, 
		[2,3]	=>	:address_message,
		[0,4]	=>	:address, 
		[0,5]	=>	:location,
		[0,6]	=>	:canton,
		[0,7]	=>	:fon,
		[0,8]	=>	:fax,
		[1,9]	=>	'explain_fon',
		[0,10]	=>	:email_suggestion,
		[1,11]	=>	:submit,
	}
	CSS_MAP = {
		[0,0,4,12]	=>	'list',	
		[0,3]	=> 'list top',
		[2,3]	=> 'list top',
		#[1,9]	=> 'small-font top',
		[1,9]	=> 'list-small',
	}
	COMPONENT_CSS_MAP = {
		[0,0,4,11]	=>	'standard',	
	}
	EVENT = :address_send
	LABELS = true
	LEGACY_INTERFACE = false
	SYMBOL_MAP = {
		:address_type				=> HtmlGrid::Select,
		:canton							=> HtmlGrid::Select,
		:email							=> HtmlGrid::InputText,
	}
	LOOKANDFEEL_MAP = {
		:message => :address_message
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
	def address_message(model)
		input = HtmlGrid::Textarea.new(:message, 
			model, @session, self)
		input.set_attribute('wrap', true)
		js = "if(this.value.length > 500) { (this.value = this.value.substr(0,500))}" 
		input.set_attribute('onKeypress', js)
		input.label = true
		input.css_class = 'standard'
		input
	end
	def email_suggestion(model)
		parent = model.pointer.parent.resolve(@session)
		input = HtmlGrid::InputText.new(:email_suggestion, 
			model, @session, self)
		if(parent.respond_to?(:email))
			input.value = parent.email
		end
		input
	end
end
class SuggestAddressComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	'suggest_addr_title',
		[0,0,1]	=>	:fullname,
		[0,1]		=>	SuggestAddressForm,
	}
	CSS_MAP = {
		[0,0]	=> 'th',
	}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def fullname(model)
		if(parent = model.pointer.parent.resolve(@session))
			parent.fullname
		end
	end
end
class SuggestAddress < PrivateTemplate
	CONTENT = View::SuggestAddressComposite
	SNAPBACK_EVENT = :result
end
	end
end
