#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::CsvResult -- oddb.org -- 19.07.2012 -- yasaka@ywesee.com
# ODDB::View::Drugs::CsvResult -- oddb.org -- 20.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::CsvResult -- oddb.org -- 28.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/component'
require 'csv'
require 'view/additional_information'

module ODDB
	module View
		module Drugs
class CsvResult < HtmlGrid::Component
  attr_reader :duplicates, :counts
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
    :ddd_dose,
    :ddd_price,
	]
  def init
    @counts = {
      'anthroposophy'            => 0,
      'bsv_dossiers'             => 0,
      'complementary'            => 0,
      'deductible_g'             => 0,
      'deductible_o'             => 0,
      'expiration_date'          => 0,
      'export_registrations'     => 0,
      'galenic_forms'            => 0,
      'generics'                 => 0,
      'has_generic'              => 0,
      'homeopathy'               => 0,
      'inactive_date'            => 0,
      'limitations'              => 0,
      'limitation_both'          => 0,
      'limitation_points'        => 0,
      'limitation_texts'         => 0,
      'lppv'                     => 0,
      'missing_size'             => 0,
      'originals'                => 0,
      'out_of_trade'             => 0,
      'phytotherapy'             => 0,
      'price_exfactory'          => 0,
      'price_public'             => 0,
      'registration_date'        => 0,
      'routes_of_administration' => 0,
      'sl_entries'               => 0,
      'renewal_flag_swissmedic'  => 0,
      # teilbarkeit
      'divisability_divisable'   => 0,
      'divisability_dissolvable' => 0,
      'divisability_crushable'   => 0,
      'divisability_openable'    => 0,
      'divisability_notes'       => 0,
      'divisability_source'      => 0,
    }
    @bsv_dossiers = {}
    @roas = {}
    @galforms = {}
    @galgroups = {}
    super
  end
	def boolean(bool)
		key = bool ? :true : :false
		@lookandfeel.lookup(key)
	end
	def bsv_dossier(pack)
		if(sl = pack.sl_entry)
      # Report package EAN code when an error happens with export_oddb_csv
      # Refer to: http://dev.ywesee.com/wiki.php/Masa/20110302-testcases-oddbOrg#DebugCsv
      begin
      dossier = sl.bsv_dossier
      rescue => e
        raise e.message + " package ean code=" + pack.barcode.to_s
      end
      if dossier
        @bsv_dossiers.store dossier, true
        @counts['bsv_dossiers'] = @bsv_dossiers.size
      end
      dossier
		end
	end
	def casrn(pack)
    ''
	end
  def c_type(pack)
    if ctype = pack.complementary_type
      @counts[ctype.to_s] += 1
      @lookandfeel.lookup("square_#{ctype}")
    end
  end
  def ddd_dose(model, session=@session)
    if(ddd = model.ddd)
      ddd.dose
    end
  end
	def deductible(pack)
    if(pack.sl_entry)
      deductible = pack.deductible || :deductible_g
      @counts[deductible.to_s] += 1
      @lookandfeel.lookup(deductible)
    end
	end
	def expiration_date(pack)
		formatted_date(pack, :expiration_date)
	end
	def export_flag(pack)
		if flag = pack.export_flag
      @counts['export_registrations'] += 1
      flag
    end
	end
	def formatted_date(pack, key)
		if(date = pack.send(key))
      @counts[key.to_s] += 1
			@lookandfeel.format_date(date)
		end
	end
  def galenic_form(pack, lang = @lookandfeel.language)
    if(galform = pack.galenic_forms.first)
      @galforms.store galform, true
      @counts['galenic_forms'] = @galforms.size
      galform.description(lang)
    end
  end
  def galenic_form_de(pack)
    galenic_form(pack, :de)
  end
  def galenic_form_fr(pack)
    galenic_form(pack, :fr)
  end
  def galenic_group(pack, lang = @lookandfeel.language)
    if(galgroup = pack.galenic_group)
      @galgroups.store galgroup, true
      @counts['galenic_groups'] = @galgroups.size
      galgroup.description(lang)
    end
  end
  def galenic_group_de(pack)
    galenic_group(pack, :de)
  end
  def galenic_group_fr(pack)
    galenic_group(pack, :fr)
  end
	def has_generic(pack)
    flag = pack.has_generic?
    if flag
      @counts['has_generic'] += 1
    end
		boolean(flag)
	end
  def self.define_division_attributes keys
    keys.each do |attribute|
      define_method(attribute) { |pack|
        if seq = pack.sequence and
           div = seq.division and
           !div.empty?
          value = div.send(attribute)
          if value
            @counts["divisability_#{attribute.to_s}"] += 1
          end
          value
        end
      }
    end
  end
  define_division_attributes [
    :divisable, :dissolvable, :crushable, :openable, :notes,
    :source
  ]
	def http_headers
		file = @session.user_input(:filename)
    if file.nil?
      file = "#{@model.search_query}.#{@session.lookandfeel.lookup(@model.search_type)}.csv"
    end
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
      lim = sl.limitation
      if lim
        @counts['limitations'] += 1
        boolean(lim)
      end
		end
	end
	def limitation_points(pack)
		if(sl = pack.sl_entry)
      points = sl.limitation_points.to_i
      if points > 0
        if sl.limitation_text
          @counts['limitation_both'] += 1
        end
        @counts['limitation_points'] += 1
        points
      end
		end
	end
	def limitation_text(pack)
		if((sl = pack.sl_entry) && (txt = sl.limitation_text))
      if txt.respond_to?(@lookandfeel.language) and lim_txt = txt.send(@lookandfeel.language).to_s
        @counts['limitation_texts'] += 1
        lim_txt.force_encoding('utf-8')
        lim_txt.gsub(/\n/u, '|')
      end
		end
	end
	def lppv(pack)
    lppv = pack.lppv
    if lppv
      @counts['lppv'] += 1
    end
		boolean(lppv)
	end
  def narcotic(pack)
    boolean(pack.narcotic?)
  end
	def numerical_size(pack)
    qty = pack.comparable_size.qty
    if qty == 0
      @counts['missing_size'] += 1
    end
    qty
	end
	def numerical_size_extended(pack)
    case ((group = pack.galenic_group) && group.de)
    when 'Brausetabletten', 'Gastrointenstinales Therapiesystem',
      'Kaugummi', 'Lutschtabletten', 'Pflaster/Transdermale Systeme',
      'Retard-Tabletten', 'Subkutane Implantate', 'Suppositorien',
      'Tabletten', 'Tests', 'Vaginal-Produkte'
      numerical_size(pack)
    else
      0
    end
	end
  def out_of_trade(pack)
    oot = !pack.public?
    if oot
      @counts['out_of_trade'] += 1
    end
		boolean(oot)
  end
	def price_exfactory(pack)
		if price = @lookandfeel.format_price(pack.price_exfactory.to_i)
      @counts['price_exfactory'] += 1
      price
    end
	end
	def price_public(pack)
		if price = @lookandfeel.format_price(pack.price_public.to_i)
      @counts['price_public'] += 1
      price
    end
	end
	def rectype(pack)
		'#Medi'
	end
	def registration_date(pack)
		formatted_date(pack, :registration_date)
	end
  def route_of_administration(pack)
    if(roa = pack.route_of_administration)
      @roas[roa.to_s] = true
      @counts['routes_of_administration'] = @roas.size
      roa.gsub('roa_', '')
    end
  end
	def sl_entry(pack)
    sl_entry = pack.sl_entry
    if sl_entry
      @counts['sl_entries'] += 1
    end
		boolean(sl_entry)
	end
  def renewal_flag_swissmedic(pack)
    renewal_flag_swissmedic = pack.renewal_flag_swissmedic
    if renewal_flag_swissmedic
      @counts['renewal_flag_swissmedic'] += 1
    end
		boolean(renewal_flag_swissmedic)
  end

  def size(model, session=@session)
    model.parts.collect { |part|
      parts = []
      multi = part.multi.to_i
      count = part.count.to_i
      if(multi > 1) 
        parts.push(multi)
      end
      if(multi > 1 && count > 1)
        parts.push('x')
      end
      if(count > 1 || multi <= 1)
        parts.push(part.count)
      end
      if(comform = part.commercial_form)
        parts.push(comform.send(@session.language))
      end
      if((measure = part.measure) && measure != 1)
        parts.push("à", measure)
      end
      parts.join(' ')
    }.join(' + ')
  end
	def generic_type(pack)
    case pack.sl_generic_type || pack.generic_type
    when :original
      @counts['originals'] += 1
      'O'
    when :generic
      @counts['generics'] += 1
      'G'
    end
	end
	def to_html(context)
		to_csv(CSV_KEYS)
	end
  def to_csv(keys, symbol=:active_packages, encoding=nil)
    result = []
    eans = {}
    index = 0
    lang = @lookandfeel.language
    header = keys.collect { |key|
      @lookandfeel.lookup("th_#{key}") || key.to_s
    }
    result.push(header)
    index += 1
    @model.each { |atc|
      result.push(['#MGrp', atc.code.to_s, atc.description(lang).to_s])
      index += 1
      ean = {}
      # Rule:
      # For the CSV Exporter only export the Product with the longer ATC-Code.
      # We export the product with the ATC-Code that has more digits
      atc.send(symbol).each { |pack|
        if(eans[pack.ikskey].nil?)
          eans[pack.ikskey] = {:cnt => 0}
        end
        eans[pack.ikskey][:cnt] += 1
        atc_code = atc.code.to_s
        if(eans[pack.ikskey][:cnt] > 1)
          if(eans[pack.ikskey][:atc].length < atc_code.length)
            result[eans[pack.ikskey][:idx]] = nil # delete
          else
            next # skip pack
          end
        end
        eans[pack.ikskey][:atc] = atc_code
        eans[pack.ikskey][:idx] = index
        line = keys.collect { |key|
          if(self.respond_to?(key))
            self.send(key, pack)
          else
            pack.send(key)
          end
        }
        result.push(line)
        index += 1
      }
    }
    result.compact.collect { |line|
      if encoding
        CSV.generate_line(line, {:col_sep => ';'}).encode(encoding, :invalid => :replace, :undef => :replace, :replace => '')
      else
        CSV.generate_line(line, {:col_sep => ';'})
      end
    }
  end
	def to_csv_file(keys, path, symbol=:active_packages, encoding=nil)
		File.open(path, 'w') { |fh| fh.puts to_csv(keys, symbol, encoding) }
	end
  def vaccine(pack)
    boolean(pack.vaccine)
  end
end
		end
	end
end
