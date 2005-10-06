#!/usr/bin/env ruby
# View::User::RegisterDownload -- oddb -- 20.09.2004 -- mhuggler@ywesee.com

require 'htmlgrid/errormessage'
require 'htmlgrid/select'
require 'view/paypal/invoice'
require 'view/publictemplate'
require 'view/datadeclaration'
require 'view/form'

module ODDB
	module View
		module User
class RegisterDownloadForm < Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:salutation,
		[0,1]	=>	:name,
		[0,2]	=>	:name_first,
		[0,3]	=>	:company_name,
		[0,4]	=>	:address,
		[0,5]	=>	:plz,
		[0,6]	=>	:location,
		[0,7]	=>	:phone,
		[0,8]	=>	:business_area,
		[0,9]	=>	:email,
		[1,10]	=>	:submit,
	}
	CSS_CLASS = 'component'
	HTML_ATTRIBUTES = {
		'style'	=>	'width:30%',
	}
	EVENT = :checkout
	LABELS = true
	CSS_MAP = {
		[0,0,2,10]	=>	'list',
		[1,11]	=> 'button',
	}
	COMPONENT_CSS_MAP = {
		[1,0,2,10]	=>	'standard',
	}
	LOOKANDFEEL_MAP = {
		:location	=> :city,
	}
	SYMBOL_MAP = {
		:salutation			=>	HtmlGrid::Select,
		:business_area	=>	HtmlGrid::Select,
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
		if(downloads = @session.user_input(:download))
			downloads.each { |key, val|
				hidden << context.hidden("download[#{key}]", val)
			}
		end
		if(months = @session.user_input(:months))
			months.each { |key, val|
				hidden << context.hidden("months[#{key}]", val)
			}
		end
		hidden
	end
end
class RegisterDownloadComposite < HtmlGrid::Composite 
	include View::PayPal::InvoiceMethods
	include View::DataDeclaration
	COMPONENTS = {
		[0,0]	=>	"register_download",
		[0,0,0]	=>	'dash_separator',
		[0,0,1]	=>	:data_declaration,
		[0,1]	=>	"register_download_descr",
		[0,2]	=>	RegisterDownloadForm,
		[1,2]	=>	:invoice_items,
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
class RegisterDownload < View::PublicTemplate
	CONTENT = RegisterDownloadComposite
end
		end
	end
end
