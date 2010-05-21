#!/usr/bin/env ruby
# OuwerkerkPlugin -- oddb -- 18.06.2003 -- hwyss@ywesee.com 

require 'date'
require 'plugin/plugin'
require 'model/dose'
require 'spreadsheet/excel'
require 'util/today'

module ODDB
  Spreadsheet.client_encoding = 'UTF-8'
	class OuwerkerkPlugin < Plugin
		RECIPIENTS = [
			'matthijs.ouwerkerk@just-medical.com',
			'Josef.Hunkeler@pue.admin.ch',
		]
		NUMERIC_FLAGS = {
			:new							=>	1,
			:sl_entry_delete	=>	2,
			:name_base  			=>	3,
			:productname			=>	3,  #legacy
			:address					=>	4,
			:ikscat						=>	5,
			:composition			=>	6, 
			:indication				=>	7,
			:sequence					=>	8, 
			:expirydate				=>	9,  #legacy
			:expiry_date			=>	9,
			:sl_entry					=>	10,
			:price						=>	11, #legacy
			:price_exfactory	=>	11, #legacy
			:price_public			=>	11, #legacy
			:comment					=>	12,
			:price_rise				=>	13,
			:delete						=>	14,
			:price_cut				=>	15,
			:not_specified		=>	16,
		}
		attr_reader :file_path
		def initialize(app, title = "med-drugs update")
			super(app)
      @title_base = title
			@file_name = @@today.strftime("med-drugs-%Y%m%d.xls")
			@file_path = File.expand_path("xls/#{@file_name}", self::class::ARCHIVE_PATH)
		end
		def export_package(pack, row, pac_flags)
			if(flags = pac_flags[pack.pointer.to_s])
				row[0] += flags
			end
			row[2] = pack.ikscd
			row[10] = pack.ikscat
			row[13] = pack.size
			if(price = pack.price_exfactory)
				row[16] = price.to_f
			end
			if(price = pack.price_public)
				row[17] = price.to_f
			end
			row[23] = pack.pharmacode
			row[24] = (pack.sl_entry.nil?) ? 'keine' : 'SL'
			row
		end
		def export_registration(reg, row, pac_flags)
			rows = []
			row[1] = reg.iksnr
			if(ind = reg.indication)
				row[6] = ind.de
			end
			row[7] = reg.export_flag ? 'Export' : ''
			if(company = reg.company)
				row[12] = reg.company.name
				row[19] = reg.company.powerlink
			end
			if(reg.sequences.empty?)
				rows.push(row)
			else
				reg.sequences.each_value { |seq|
					seqrow = row.dup
					rows += export_sequence(seq, seqrow, pac_flags)
				}
			end
			rows
		end
		def export_registrations
			if(lgrp = @app.log_group(:swissmedic))
				@smj = lgrp.latest
			end
			if(lgrp = @app.log_group(:bsv_sl))
				@bsv = lgrp.latest
			end
			registrations = @smj.nil? ? {} : @smj.change_flags
			packages = @bsv.nil? ? {} : @bsv.change_flags

			# Hash-Table lookups fail for p1 == p2, if p1.id != p2.id
			# we can work around that problem using the serialized form p1.to_s
			pointer_table = {}
			reg_flags = {}
			pac_flags = {}
			registrations.each { |pointer, flags| 
				key = pointer.to_s
				pointer_table.store(key, pointer)
				if(flags.empty?)
					flags.push(:not_specified)
				end
				reg_flags.store(key, flags)
			}
			packages.each { |pointer, flags|
				ptr = pointer.parent.parent
				key = ptr.to_s
				reg_flags[key] ||= []
				pointer_table.store(key, ptr)
				pac_flags.store(pointer.to_s, flags)
			}

			rows = []
			reg_flags.each { |ptr_str, flags|
				if(reg = pointer_table[ptr_str].resolve(@app))
					rows += export_registration(reg, [flags], pac_flags)
				end
			}
			rows.delete_if { |row| 
				row[0] = row[0].collect { |flg| 
					self::class::NUMERIC_FLAGS[flg] 
				}.compact.uniq.sort
				row.first.empty?
			}
			rows.sort_by { |row| 
				[ 
					row.first, 
					row.at(4).to_s, 
					row.at(1).to_i, 
					row.at(3).to_i, 
					row.at(2).to_i 
				] 
			}.collect { |row|
				row[0] = row.first.join(',')
				row
			}
		end
		def export_sequence(seq, row, pac_flags)
			rows = []
			row[3,2] = [
				seq.seqnr,
				seq.name,
			]
      ## Sequence#dose is obsolete - it's just a sum of all ActiveAgent's Doses
			if (dose = seq.dose) && dose.is_a?(Dose)
				row[8,2] = [
					dose.qty,
					dose.unit,
				]
			end
			row[11] = seq.active_agents.size
      seq.galenic_forms.collect { |galform|
				row[14] = galform.de
      }.join(', ')
			row[15] = seq.composition_text
			if(atc = seq.atc_class)
				row[21] = atc.code
			end
			if(seq.packages.empty?)
				rows << row
			else
				seq.packages.each_value { |pack| 
					prow = row.dup
					rows << export_package(pack, prow, pac_flags)
				}
			end
			rows
		end
		def export_xls opts={}
			#require 'debug'
			rows = export_registrations
      if opts[:remove_newlines]
        rows.each do |row|
          row.each do |data|
            if data.is_a?(String)
              data.gsub! /[\n\r]+/u, ' / '
            end
          end
        end
      end
			dir = File.dirname(@file_path)
			Dir.mkdir(dir) unless File.exists?(dir)
			workbook = Spreadsheet::Excel.new(@file_path)
			#fmt_default = Format.new(:bg_color => 0x7FFF)
			#workbook.instance_variable_set('@format', fmt_default)
			fmt_title = Spreadsheet::Format.new(:bold=>true)#, :bg_color => 0x7FFF)
			english = Spreadsheet::Format.new(:bold=>true,:color=>"green")#, :bg_color => 0x7FFF)
			german = Spreadsheet::Format.new(:bold=>true,:color=>"red")#, :bg_color => 0x7FFF)
			workbook.add_format(fmt_title)
			workbook.add_format(english)
			workbook.add_format(german)
			worksheet = workbook.add_worksheet(@title_base)
			worksheet.write(0, 0, title(), fmt_title)
			en = [ 
				'group', 'IKSNo', 'CD', 'sequence', 'product', 'customization',
				'usage', 'Export', 'dosage', 'unit', 'selling group',
				'No. of active substances', 'company', 'package', 'galenic',
				'composition', 'price exfactory', 'public prize', 'URL product',
				'URL company', 'Position', 'ATC code', 'info', 'pharma code', 'list',
			]
			worksheet.write(1, 0, en, english)
			de = [
				'Kategorie', 'Zul.-Nr.', 'CD', 'SEQNR', 'Präparatename', 'Handelsform',
				'Heilmittelcode', 'Export', 'DOSIS', 'Einheit', 'Abgabe-kategorie',
				'Wirkstoff-anzahl', 'Vertriebsname', 'Packungsgrösse', 'Gal. Form',
				'Zusammensetzung', 'Preis ex fac', 'Preis pub', 'Link Produkt',
				'Link Firma', 'Position', 'ATC Nummer', 'info', 'Pharmacode', 'Liste',
			]
			worksheet.write(2, 0, de, german)
			rows.each_with_index { |row, idx|
				worksheet.write(idx+3, 0, row)
			}
			workbook.close
		end
		def log_info
			hash = super
			if @file_path
				hash.store(:files, { @file_path => "application/vnd.ms-excel"}) 
			end
			hash.store(:date_str, date_str)
			hash
		end
		def title
			@title ||= @title_base + " #{date_str}"
		end
		alias :report :title
		private
		def date_str
			[
				(@smj.date.strftime("Swissmedic %m/%Y") unless @smj.nil?),
				(@bsv.date.strftime("SL %m/%Y") unless @bsv.nil?),
			].compact.join(" - ")
		end
	end
end
