#!/usr/bin/env ruby
# View::Drugs::PaymentMethod -- oddb -- 05.10.2005 -- hwyss@ywesee.com

require 'view/resulttemplate'
require 'view/datadeclaration'

module ODDB
	module View
		module Drugs
class PaymentMethodForm < Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:company_name,
		[0,1]	=>	:fullname,
		[0,2]	=>	:email,
		[0,3]	=>	:payment_method,
		[1,4]	=>	:submit,
	}
	CSS_CLASS = 'component'
	HTML_ATTRIBUTES = {
		'style'	=>	'width:30%',
	}
	EVENT = :proceed_payment
	LABELS = true
	CSS_MAP = {
		[0,0,2,5]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[0,0,2,3]	=>	'standard',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	SYMBOL_MAP = {
		:payment_method	=>	HtmlGrid::Select,
	}
  LOOKANDFEEL_MAP = {
    :fullname => :contact,
  }
	def init
		super
		if(@session.error?)
			error = RuntimeError.new('e_need_all_input')
			__message(error, 'processingerror')
		end
	end
	def hidden_fields(context)
		hidden = super
		[:search_query, :search_type].each { |key|
			hidden << context.hidden(key.to_s, @session.state.send(key))
		}	
		hidden
	end
end
class PaymentMethodComposite < HtmlGrid::Composite 
	include View::PayPal::InvoiceMethods
	include View::DataDeclaration
	COMPONENTS = {
		[0,0,0]	=>	"export_csv",
		[0,0,1]	=>	'dash_separator',
		[0,0,2]	=>	"payment_method",
		[0,0,3]	=>	'dash_separator',
		[0,0,4]	=>	:data_declaration,
		[0,1]		=>	"payment_method_descr",
		[0,2]		=>	PaymentMethodForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'list',
	}
	LEGACY_INTERFACE = false
end
class PaymentMethod < View::ResultTemplate
	CONTENT = PaymentMethodComposite
end
		end
	end
end
