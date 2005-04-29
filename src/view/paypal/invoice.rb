#!/usr/bin/env ruby
# View::PayPal::Invoice -- ODDB -- 28.04.2005 -- hwyss@ywesee.com

module ODDB
	module View
		module PayPal
class InvoiceItems < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:quantity,
		[1,0]	=>	:text,
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
	def text(model)
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
module InvoiceMethods
	def invoice_items(model)
		View::PayPal::InvoiceItems.new(model.items, @session, self)
	end
end
		end
	end
end
