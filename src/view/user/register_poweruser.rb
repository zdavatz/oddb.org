#!/usr/bin/env ruby
# View::User::RegisterPowerUser -- oddb -- 29.07.2005 -- hwyss@ywesee.com

require 'view/resulttemplate'
require 'view/paypal/invoice'
require 'htmlgrid/pass'

module ODDB
	module View
		module User
class RegisterPowerUserForm < Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:salutation,
		[0,1]	=>	:name,
		[0,2]	=>	:name_first,
		[0,3]	=>	:email,
		[0,4]	=>	:pass,
		[3,4]	=>	:set_pass_2,
		[1,5]	=>	:submit,
	}
	CSS_CLASS = 'component'
	EVENT = :checkout
	LABELS = true
	CSS_MAP = {
		[0,0,4,6]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,4,5]	=>	'standard',
	}
	SYMBOL_MAP = {
		:salutation	=>	HtmlGrid::Select,
		:pass				=>	HtmlGrid::Pass,
		:set_pass_2	=>	HtmlGrid::Pass,
	}
	def init
		super
		error_message
	end
end
class RegisterPowerUserComposite < HtmlGrid::Composite 
	include View::PayPal::InvoiceMethods
	COMPONENTS = {
		[0,0]		=>	"power_user",
		[0,1]		=>	"power_user_descr",
		[0,2]		=>	RegisterPowerUserForm,
		[1,2]		=>	:invoice_items,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2]	=>	'th',
		[0,1]	=>	'list',
	}
	COLSPAN_MAP = {
		[0,0] => 2,
		[0,1] => 2,
	}
	LEGACY_INTERFACE = false
end
class RegisterPowerUser < View::ResultTemplate
	CONTENT = RegisterPowerUserComposite
end
class RenewPowerUserForm < RegisterPowerUserForm
	COMPONENTS = {
		[0,0]	=>	:name,
		[0,1]	=>	:email,
		[1,2]	=>	:submit,
	}
	CSS_MAP = {
		[0,0,2,3]	=>	'list',
	}
	COMPONENT_CSS_MAP = {}
	DEFAULT_CLASS = HtmlGrid::Value
	SYMBOL_MAP = {}
	def name(model, session)
		user = @session.user
		salutation = if(user.respond_to?(:salutation))
			@lookandfeel.lookup(@session.user.salutation)
		end
		text = HtmlGrid::Text.new(:name, model, @session, self)
		text.value = [
			salutation, 
			model.name_first,
			model.name
		].compact.join(' ')
		text.label = true
		text
	end
end
class RenewPowerUserComposite < HtmlGrid::Composite 
	include View::PayPal::InvoiceMethods
	COMPONENTS = {
		[0,0]		=>	"renew_poweruser_header",
		[0,1]		=>	:renew_poweruser_form,
		[1,1]		=>	:invoice_items,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2]	=>	'th',
		[0,1]	=>	'list',
	}
	COLSPAN_MAP = {
		[0,0] => 2,
	}
	LEGACY_INTERFACE = false
	def renew_poweruser_form(model)
		RenewPowerUserForm.new(@session.user, @session, self)
	end
end
class RenewPowerUser < View::ResultTemplate
	CONTENT = RenewPowerUserComposite
end
		end
	end
end
