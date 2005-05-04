#!/usr/bin/env ruby
# View::Drugs::CsvResult -- ODDB -- 28.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/component'
require 'csvparser'
require 'view/additional_information'

module ODDB
	module View
		module Drugs
class CsvResult < HtmlGrid::Component
	CSV_KEYS = [
		:barcode,
		:name_base,
		:galenic_form,
		:most_precise_dose,
		:size,
		:numerical_size,
		:price_exfactory,
		:price_public,
		:company_name,
		:ikscat,
		:sl_entry,
		:registration_date,
	]
	def galenic_form(pack)
		if(galform = pack.galenic_form)
			galform.description(@lookandfeel.language)
		end
	end
	def http_headers
		file = @session.user_input(:filename)
		{
			'Content-Type'				=>	'text/csv',
			'Content-Disposition'	=>	"attachment;filename=#{file}",
		}
	end
	def numerical_size(pack)
		pack.comparable_size.qty
	end
	def price_exfactory(pack)
		@lookandfeel.format_price(pack.price_exfactory.to_i)
	end
	def price_public(pack)
		@lookandfeel.format_price(pack.price_public.to_i)
	end
	def registration_date(pack)
		if(date = pack.registration_date)
			@lookandfeel.format_date(date)
		end
	end
	def sl_entry(pack)
		if(pack.sl_entry)
			@lookandfeel.lookup(:sl)
		end
	end
	def to_html(context)
		result = []
		lang = @lookandfeel.language
		header = CSV_KEYS.collect { |key|
			@lookandfeel.lookup("th_#{key}")
		}
		result.push(header)
		@model.each { |atc|
			result.push([atc.code.to_s, atc.description(lang).to_s])
			atc.packages.each { |pack|
				line = CSV_KEYS.collect { |key|
					if(self.respond_to?(key))
						self.send(key, pack)
					else
						pack.send(key)
					end.to_s
				}
				result.push(line)
			}
		}
		result.collect { |line|
			CSVLine.new(line).to_s(false, ';')
		}.join("\n")
	end
end
		end
	end
end
