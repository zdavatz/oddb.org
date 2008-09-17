#!/usr/bin/env ruby
# View::Drugs::RegisterDownload -- ODDB -- 28.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/errormessage'
require 'htmlgrid/select'
require 'view/resulttemplate'
require 'view/paypal/invoice'
require 'view/datadeclaration'
require 'view/form'
require 'view/user/autofill'

module ODDB
	module View
		module Drugs
class RegisterDownloadForm < Form
  include View::User::AutoFill
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:email,
		[0,1]	=>	:salutation,
		[0,2]	=>	:name_last,
		[0,3]	=>	:name_first,
		[1,4] =>	:submit,
	}
	CSS_CLASS = 'component'
	HTML_ATTRIBUTES = {
		'style'	=>	'width:30%',
	}
	EVENT = :checkout
	LABELS = true
	CSS_MAP = {
		[0,0,4,5]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,3,4]	=>	'standard',
	}
	SYMBOL_MAP = {
		:pass				    =>	HtmlGrid::Pass,
		:set_pass_2	    =>	HtmlGrid::Pass,
		:salutation			=>	HtmlGrid::Select,
	}
	def init
    unless(@session.logged_in?)
      hash_insert_row(components, [0,1], :pass)
      components.store([3,1], :set_pass_2)
      css_map.store([0,11,4], 'list')
		  component_css_map.store([1,10], 'standard')
    end
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
	def submit(model, session=@session)
		super(model, session, :checkout_paypal)
	end
end
class RegisterDownloadComposite < HtmlGrid::Composite 
	include View::PayPal::InvoiceMethods
	include View::DataDeclaration
	COMPONENTS = {
		[0,0]		=>	SelectSearchForm,
		[0,1,0]	=>	"export_csv",
		[0,1,1]	=>	'dash_separator',
		[0,1,2]	=>	:data_declaration,
		[0,2]		=>	"export_csv_descr",
		[0,3]		=>	RegisterDownloadForm,
		[1,3]		=>	:invoice_items,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
    [0,0] =>  'right',
		[0,1,2]	=>	'th',
		[0,2]	=>	'list',
	}
	COLSPAN_MAP = {
		[0,0] => 2,
		[0,1] => 2,
		[0,2] => 2,
	}
	LEGACY_INTERFACE = false
end
class RegisterDownload < View::ResultTemplate
  JAVASCRIPTS = ['autofill']
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
		[0,0]		=>	SelectSearchForm,
		[0,1,0]	=>	"export_csv",
		[0,1,1]	=>	'dash_separator',
		[0,1,2]	=>	:data_declaration,
		[0,2]		=>	:invoice_descr,
		[0,3]		=>	:invoice_items,
		[0,4]		=>	RegisterInvoicedDownloadForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'right',
		[0,1]	=>	'th',
		[0,2,1,3]	=>	'list',
	}
	COLSPAN_MAP = {
		[0,0] => 2,
		[0,1] => 2,
		[0,2] => 2,
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
