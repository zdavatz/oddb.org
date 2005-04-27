#!/usr/bin/env ruby
# View::User::RegisterDownload -- oddb -- 20.09.2004 -- mhuggler@ywesee.com

require 'htmlgrid/errormessage'
require 'htmlgrid/select'
require 'view/publictemplate'
require 'view/logohead'
require 'view/form'

module ODDB
	module View
		module User
class RegisterDownloadInvoice < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:quantity,
		[1,0]	=>	:download,
		[2,0]	=>	:price,
	}
	CSS_CLASS = 'invoice top'
	CSS_MAP = {
		[0,0]	=>	'list-r',
		[1,0]	=>	'list',
		[2,0]	=>	'list-r',
	}
	LEGACY_INTERFACE = false
	OMIT_HEADER = true
	STRIPED_BG = false
	def compose_footer(matrix)
		total_net = ['', @lookandfeel.lookup(:total_netto), total_netto()]
		vat = ['', @lookandfeel.lookup(:vat), vat()]
		total = ['', @lookandfeel.lookup(:total_brutto), total_brutto()]
		@grid.add(total_net, *matrix)
		@grid.add_style('list-bg', matrix.at(0), matrix.at(1), 2)
		@grid.add_style('list-r-bg', *resolve_offset(matrix, [2,0]))
		matrix = resolve_offset(matrix, [0,1])
		@grid.add(vat, *matrix)
		@grid.add_style('list-bg', matrix.at(0), matrix.at(1), 2)
		@grid.add_style('list-r-bg', *resolve_offset(matrix, [2,0]))
		matrix = resolve_offset(matrix, [0,1])
		@grid.add(total, *matrix)
		@grid.add_style('list-bg bold', matrix.at(0), matrix.at(1), 2)
		@grid.add_style('list-r-bg bold', *resolve_offset(matrix, [2,0]))
	end
	def download(model)
		model.text
	end
	def format_price(price, currency=nil)
		@lookandfeel.format_price(price.to_f * 100.0, currency)
	end
	def price(model)
		format_price(model.total_netto)
	end
	def quantity(model)
		model.quantity.to_i.to_s << ' x'
	end
	def total_brutto
		format_price(@model.inject(0) { |inj, item|
			inj + item.total_brutto
		}, 'EUR')
	end
	def total_netto
		format_price @model.inject(0) { |inj, item|
			inj + item.total_netto
		}
	end
	def vat
		format_price @model.inject(0) { |inj, item|
			inj + item.vat
		}
	end
end
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
		@model.downloads.each { |name|
			hidden << context.hidden("download[#{name}]", '1')
		}
		hidden
	end
end
class RegisterDownloadComposite < HtmlGrid::Composite 
	COMPONENTS = {
		[0,0]	=>	"register_download",
		[0,1]	=>	"register_download_descr",
		[0,2]	=>	RegisterDownloadForm,
		[1,2]	=>	:invoice,
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
	def invoice(model)
		RegisterDownloadInvoice.new(model.downloads, @session, self)
	end
end
class RegisterDownload < View::PublicTemplate
	CONTENT = RegisterDownloadComposite
end
		end
	end
end
