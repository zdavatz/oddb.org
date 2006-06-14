#!/usr/bin/env ruby
# View::Drugs::RegisterDownload -- ODDB -- 28.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/errormessage'
require 'htmlgrid/select'
require 'view/resulttemplate'
require 'view/paypal/invoice'
require 'view/datadeclaration'
require 'view/form'

module ODDB
	module View
		module Drugs
class RegisterDownloadForm < Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:salutation,
		[0,1]	=>	:name,
		[0,2]	=>	:name_first,
		[0,3]	=>	:email,
		[1,4]	=>	:submit,
	}
	CSS_CLASS = 'component'
	HTML_ATTRIBUTES = {
		'style'	=>	'width:30%',
	}
	EVENT = :checkout
	LABELS = true
	CSS_MAP = {
		[0,0,2,5]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,2,4]	=>	'standard',
	}
	SYMBOL_MAP = {
		:salutation			=>	HtmlGrid::Select,
	}
	def init
		super
		if(@session.error?)
			error = RuntimeError.new('e_need_all_input')
			message(error, 'processingerror')
		end
	end
	def hidden_fields(context)
		hidden = super
		[:search_query, :search_type].each { |key|
			hidden << context.hidden(key.to_s, @session.state.send(key))
		}	
		hidden
	end
	def submit(model, session=@session)
		super(model, session, :checkout_paypal)
	end
end
class RegisterDownloadComposite < HtmlGrid::Composite 
	include View::PayPal::InvoiceMethods
	include View::DataDeclaration
	COMPONENTS = {
		[0,0]		=>	"export_csv",
		[0,0,0]	=>	'dash_separator',
		[0,0,1]	=>	:data_declaration,
		[0,1]		=>	"export_csv_descr",
		[0,2]		=>	RegisterDownloadForm,
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
class RegisterDownload < View::ResultTemplate
	CONTENT = RegisterDownloadComposite
end
class RegisterInvoicedDownloadForm < Form
	EVENT = :checkout
	COMPONENTS = {
		[0,0]	=>	:submit,
	}
	def submit(model, session=@session)
		super(model, session, :checkout_invoice)
	end
end
class RegisterInvoicedDownloadComposite < HtmlGrid::Composite 
	include View::PayPal::InvoiceMethods
	include View::DataDeclaration
	COMPONENTS = {
		[0,0]		=>	"export_csv",
		[0,0,0]	=>	'dash_separator',
		[0,0,1]	=>	:data_declaration,
		[0,1]		=>	:invoice_descr,
		[0,2]		=>	:invoice_items,
		[0,3]		=>	RegisterInvoicedDownloadForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1,1,3]	=>	'list',
	}
	COLSPAN_MAP = {
		[0,0] => 2,
		[0,1] => 2,
	}
	LEGACY_INTERFACE = false
	def invoice_descr(model)
		date = if(@@today.day < 15) 
			Date.new(@@today.year, @@today.month, 15)
		else
			Date.new(@@today.year, @@today.month) >> 1
		end
		@lookandfeel.lookup(:invoice_descr, 
			date.strftime(@lookandfeel.lookup(:date_format)),
			@session.user.unique_email)
	end
end
class RegisterInvoicedDownload < View::ResultTemplate
	CONTENT = RegisterInvoicedDownloadComposite
end
		end
	end
end
