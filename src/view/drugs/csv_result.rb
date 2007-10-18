#!/usr/bin/env ruby
# View::Drugs::CsvResult -- ODDB -- 28.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/component'
require 'csv'
require 'view/additional_information'

module ODDB
	module View
		module Drugs
class CsvResult < HtmlGrid::Component
  attr_reader :duplicates
	CSV_KEYS = [
		:rectype,
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
		:casrn,
	]
	def boolean(bool)
		key = bool ? :true : :false
		@lookandfeel.lookup(key)
	end
	def bsv_dossier(pack)
		if(sl = pack.sl_entry)
			sl.bsv_dossier
		end
	end
	def casrn(pack)
		str = pack.narcotics.collect { |narc|
			narc.casrn
		}.compact.join(',')
    str unless str.empty?
	end
  def c_type(pack)
    @lookandfeel.lookup("square_#{pack.complementary_type}")
  end
	def deductible(pack)
    if(pack.sl_entry)
      @lookandfeel.lookup(pack.deductible || :deductible_g)
    end
	end
	def expiration_date(pack)
		formatted_date(pack, :expiration_date)
	end
	def export_flag(pack)
		pack.export_flag
	end
	def formatted_date(pack, key)
		if(date = pack.send(key))
			@lookandfeel.format_date(date)
		end
	end
	def galenic_form(pack)
		if(galform = pack.galenic_form)
			galform.description(@lookandfeel.language)
		end
	end
	def has_generic(pack)
		boolean(pack.generic_type == :original && !pack.comparables.empty?)
	end
	def http_headers
		file = @session.user_input(:filename)
		url = @lookandfeel._event_url(:home)
		{
			'Content-Type'				=>	'text/csv',
			'Content-Disposition'	=>	"attachment;filename=#{file}",
		}
	end
	def inactive_date(pack)
		formatted_date(pack, :inactive_date)
	end
	def introduction_date(pack)
		if((sl = pack.sl_entry) && (date = sl.introduction_date))
			@lookandfeel.format_date(date)
		end
	end
	def limitation(pack)
		if(sl = pack.sl_entry)
			boolean(sl.limitation)
		end
	end
	def limitation_points(pack)
		if(sl = pack.sl_entry)
			sl.limitation_points
		end
	end
	def limitation_text(pack)
		if((sl = pack.sl_entry) && (txt = sl.limitation_text))
			txt.send(@lookandfeel.language).to_s.gsub(/\n/, '|')
		end
	end
	def lppv(pack)
		boolean(pack.lppv)
	end
	def numerical_size(pack)
    pack.comparable_size.qty
	end
	def numerical_size_extended(pack)
    case pack.route_of_administration
    when 'roa_P'
      multi = pack.multi.to_i
      (multi > 1) ? multi : pack.count.to_i
    else
      numerical_size(pack)
    end
	end
  def out_of_trade(pack)
		boolean(!pack.public?)
  end
	def price_exfactory(pack)
		@lookandfeel.format_price(pack.price_exfactory.to_i)
	end
	def price_public(pack)
		@lookandfeel.format_price(pack.price_public.to_i)
	end
	def rectype(pack)
		'#Medi'
	end
	def registration_date(pack)
		formatted_date(pack, :registration_date)
	end
  def route_of_administration(pack)
    if(roa = pack.route_of_administration)
      roa.gsub('roa_', '')
    end
  end
	def sl_entry(pack)
		boolean(pack.sl_entry)
	end
	def generic_type(pack)
    case pack.sl_generic_type || pack.generic_type
    when :original
      'O'
    when :generic
      'G'
    end
	end
	def to_html(context)
		to_csv(CSV_KEYS)
	end
	def to_csv(keys, symbol=:active_packages)
    eans = {}
		result = []
		lang = @lookandfeel.language
		header = keys.collect { |key|
			@lookandfeel.lookup("th_#{key}") || key.to_s
		}
		result.push(header)
		@model.each { |atc|
			result.push(['#MGrp', atc.code.to_s, atc.description(lang).to_s])
			atc.send(symbol).each { |pack|
        eans[pack.ikskey] = eans[pack.ikskey].to_i + 1
				line = keys.collect { |key|
					if(self.respond_to?(key))
						self.send(key, pack)
					else
						pack.send(key)
					end
				}
				result.push(line)
			}
		}
    @duplicates = eans.collect { |ikskey, count| 
      ikskey if count > 1 }.compact.sort
		result.collect { |line|
			CSV.generate_line(line, ';')
		}.join("\n")
	end
	def to_csv_file(keys, path, symbol=:active_packages)
		File.open(path, 'w') { |fh| fh.puts to_csv(keys, symbol) }
	end
end
		end
	end
end
