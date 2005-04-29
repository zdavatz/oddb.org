#!/usr/bin/env ruby
# View::Drugs::RegisterDownload -- ODDB -- 28.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/errormessage'
require 'view/resulttemplate'
require 'view/paypal/invoice'
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
end
class RegisterDownloadComposite < HtmlGrid::Composite 
	include View::PayPal::InvoiceMethods
	COMPONENTS = {
		[0,0]	=>	"export_csv",
		[0,1]	=>	"export_csv_descr",
		[0,2]	=>	RegisterDownloadForm,
		[1,2]	=>	:invoice_items,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2]	=>	'th',
		[0,1]	=>	'list',
	}
	COLSPAN_MAP = {
		[0,1] => 2,
	}
	LEGACY_INTERFACE = false
end
class RegisterDownload < View::ResultTemplate
	CONTENT = RegisterDownloadComposite
end
		end
	end
end
