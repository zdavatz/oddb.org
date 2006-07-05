#!/usr/bin/env ruby
# View::User::RegisterPowerUser -- oddb -- 29.07.2005 -- hwyss@ywesee.com

require 'view/resulttemplate'
require 'view/paypal/invoice'
require 'view/user/autofill'
require 'htmlgrid/pass'
require 'htmlgrid/errormessage'

module ODDB
	module View
		module User
class RegisterPowerUserForm < Form
  include AutoFill
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:email,
		[0,1]	=>	:pass,
		[3,1]	=>	:set_pass_2,
		[0,2]	=>	:salutation,
		[0,3]	=>	:name_last,
		[0,4]	=>	:name_first,
		[1,5]	=>	:submit,
	}
	CSS_CLASS = 'component'
	EVENT = :checkout
	LABELS = true
  LEGACY_INTERFACE = false
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
  JAVASCRIPTS = ['autofill']
	CONTENT = RegisterPowerUserComposite
end
class RenewPowerUserForm < RegisterPowerUserForm
	COMPONENTS = {
		[0,0]	=>	:email,
		[0,1]	=>	:salutation,
		[0,2]	=>	:name_last,
		[0,3]	=>	:name_first,
		[1,4]	=>	:submit,
	}
	CSS_MAP = {
		[0,0,2,5]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,4,4]	=>	'standard',
	}
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
