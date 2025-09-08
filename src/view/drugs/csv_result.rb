#!/usr/bin/env ruby

# ODDB::View::Drugs::CsvResult -- oddb.org -- 11.04.2013 -- yasaka@ywesee.com
# ODDB::View::Drugs::CsvResult -- oddb.org -- 20.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::CsvResult -- oddb.org -- 28.04.2005 -- hwyss@ywesee.com

require "htmlgrid/component"
require "csv"
require "view/additional_information"

module ODDB
  module View
    module Drugs
      class CsvResult < HtmlGrid::Component
        attr_reader :duplicates, :counts, :total,
          :divisions, :flickr_photos
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
          :ddd_price
        ]
        def init
          @counts = {
            "anthroposophy" => 0,
            "bsv_dossiers" => 0,
            "deductible_g" => 0,
            "deductible_o" => 0,
            "expiration_date" => 0,
            "export_registrations" => 0,
            "galenic_forms" => 0,
            "generics" => 0,
            "has_generic" => 0,
            "homeopathy" => 0,
            "inactive_date" => 0,
            "limitations" => 0,
            "limitation_both" => 0,
            "limitation_points" => 0,
            "limitation_texts" => 0,
            "lppv" => 0,
            "missing_size" => 0,
            "originals" => 0,
            "out_of_trade" => 0,
            "phytotherapy" => 0,
            "price_exfactory" => 0,
            "price_public" => 0,
            "registration_date" => 0,
            "routes_of_administration" => 0,
            "sl_entries" => 0,
            "renewal_flag_swissmedic" => 0
          }
          @total = 0
          @bsv_dossiers = {}
          @roas = {}
          @galforms = {}
          @galgroups = {}
          @divisions = {
            "divisable" => 0,
            "dissolvable" => 0,
            "crushable" => 0,
            "openable" => 0,
            "notes" => 0,
            "source" => 0
          }
          @flickr_photos = {
            "barcode" => 0,
            "flickr_photo_id" => 0,
            "iksnr" => 0,
            "seqnr" => 0
          }
          super
        end

        def boolean(bool)
          key = bool ? :true : :false
          @lookandfeel.lookup(key)
        end

        def bsv_dossier(pack)
          if pack && sl = pack.sl_entry
            # Report package EAN code when an error happens with export_oddb_csv
            # Refer to: http://dev.ywesee.com/wiki.php/Masa/20110302-testcases-oddbOrg#DebugCsv
            begin
              dossier = sl.bsv_dossier
              if dossier
                @bsv_dossiers.store dossier, true
                @counts["bsv_dossiers"] = @bsv_dossiers.size
              end
              dossier
            rescue
              "missing_sl_entry(.dossier) package ean code=" + pack.barcode.to_s
            end
          end
        end

        def casrn(pack)
          ""
        end

        def c_type(pack)
          if (ctype = pack.complementary_type) and ctype
            @counts[ctype.to_s] ||= 0
            @counts[ctype.to_s] += 1
            @lookandfeel.lookup("square_#{ctype}")
          end
        end

        def ddd_dose(model, session = @session)
          if (ddd = model.ddd)
            ddd.dose
          end
        end

        def deductible(pack)
          if pack.sl_entry
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
            @counts["export_registrations"] += 1
            flag
          end
        end

        def formatted_date(pack, key)
          if (date = pack.send(key))
            @counts[key.to_s] += 1
            @lookandfeel.format_date(date)
          end
        end

        def galenic_form(pack, lang = @lookandfeel.language)
          if (galform = pack.galenic_forms.first)
            @galforms.store galform, true
            @counts["galenic_forms"] = @galforms.size
            galform.description(lang)
          end
        end

        def galenic_form_de(pack)
          galenic_form(pack, "de")
        end

        def galenic_form_fr(pack)
          galenic_form(pack, "fr")
        end

        def galenic_group(pack, lang = @lookandfeel.language)
          if (galgroup = pack.galenic_group)
            @galgroups.store galgroup, true
            @counts["galenic_groups"] = @galgroups.size
            galgroup.description(lang)
          end
        end

        def galenic_group_de(pack)
          galenic_group(pack, "de")
        end

        def galenic_group_fr(pack)
          galenic_group(pack, "fr")
        end

        def has_generic(pack)
          flag = pack.has_generic?
          if flag
            @counts["has_generic"] += 1
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
                if value and !value.empty?
                  @divisions[attribute.to_s] += 1
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
          @lookandfeel._event_url(:home)
          {
            "Content-Type"	=>	"text/csv",
            "Content-Disposition"	=>	"attachment;filename=#{file}"
          }
        end

        def inactive_date(pack)
          formatted_date(pack, :inactive_date)
        end

        def introduction_date(pack)
          if (sl = pack.sl_entry)
            begin
              date = sl.introduction_date
              @lookandfeel.format_date(date)
            rescue
              "missing sl_entry package ean code=" + pack.barcode.to_s
            end
          end
        end

        def limitation(pack)
          if (sl = pack.sl_entry)
            begin
              lim = sl.limitation
              if lim
                @counts["limitations"] += 1
                boolean(lim)
              end
            rescue
              "missing sl_entry(.limitation) package ean code=" + pack.barcode.to_s
            end
          end
        end

        def limitation_points(pack)
          if (sl = pack.sl_entry)
            begin
              points = sl.limitation_points.to_i
              if points > 0
                if sl.limitation_text
                  @counts["limitation_both"] += 1
                end
                @counts["limitation_points"] += 1
                points
              end
            rescue
              "missing sl_entry(.limitation_points) package ean code=" + pack.barcode.to_s
            end
          end
        end

        def limitation_text(pack)
          if (sl = pack.sl_entry)
            begin
              txt = sl.limitation_text
              if txt.respond_to?(@lookandfeel.language) and lim_txt = txt.send(@lookandfeel.language).to_s
                @counts["limitation_texts"] += 1
                lim_txt.encode("utf-8")
                lim_txt.gsub(/\n/u, "|")
              end
            rescue
              "missing sl_entry(.limitation_text) package ean code=" + pack.barcode.to_s
            end
          end
        end

        def lppv(pack)
          lppv = pack.lppv
          if lppv
            @counts["lppv"] += 1
          end
          boolean(lppv)
        end

        def narcotic(pack)
          boolean(pack.narcotic?)
        end

        def numerical_size(pack)
          qty = pack.comparable_size.qty
          if qty == 0
            @counts["missing_size"] += 1
          end
          qty
        end

        def numerical_size_extended(pack)
          case (group = pack.galenic_group) && group.de
          when "Brausetabletten", "Gastrointenstinales Therapiesystem",
            "Kaugummi", "Lutschtabletten", "Pflaster/Transdermale Systeme",
            "Retard-Tabletten", "Subkutane Implantate", "Suppositorien",
            "Tabletten", "Tests", "Vaginal-Produkte"
            numerical_size(pack)
          else
            0
          end
        end

        def out_of_trade(pack)
          oot = !pack.public?
          if oot
            @counts["out_of_trade"] += 1
          end
          boolean(oot)
        end

        def price_exfactory(pack)
          if price = @lookandfeel.format_price(pack.price_exfactory.to_i)
            @counts["price_exfactory"] += 1
            price
          end
        end

        def price_public(pack)
          if price = @lookandfeel.format_price(pack.price_public.to_i)
            @counts["price_public"] += 1
            price
          end
        end

        def rectype(pack)
          "#Medi"
        end

        def registration_date(pack)
          formatted_date(pack, :registration_date)
        end

        def route_of_administration(pack)
          if (roa = pack.route_of_administration)
            @roas[roa.to_s] = true
            @counts["routes_of_administration"] = @roas.size
            roa.gsub("roa_", "")
          end
        end

        def sl_entry(pack)
          sl_entry = pack.sl_entry
          if sl_entry
            @counts["sl_entries"] += 1
          end
          boolean(sl_entry)
        end

        def renewal_flag_swissmedic(pack)
          renewal_flag_swissmedic = pack.renewal_flag_swissmedic
          if renewal_flag_swissmedic
            @counts["renewal_flag_swissmedic"] += 1
          end
          boolean(renewal_flag_swissmedic)
        end

        def size(model, session = @session)
          model.parts.collect { |part|
            parts = []
            multi = part.multi.to_i
            count = part.count.to_i
            if multi > 1
              parts.push(multi)
            end
            if multi > 1 && count > 1
              parts.push("x")
            end
            if count > 1 || multi <= 1
              parts.push(part.count)
            end
            if (comform = part.commercial_form)
              parts.push(comform.send(@session.language))
            end
            if (measure = part.measure) && measure != 1
              parts.push("à", measure)
            end
            parts.join(" ")
          }.join(" + ")
        end

        def generic_type(pack)
          case pack.sl_generic_type || pack.generic_type
          when :original
            @counts["originals"] += 1
            "O"
          when :generic
            @counts["generics"] += 1
            "G"
          end
        end

        def to_html(context)
          to_csv(CSV_KEYS)
        end

        def header(keys, opts = nil)
          header = keys.collect { |key|
            @lookandfeel.lookup("th_#{key}") || key.to_s
          }
          if opts
            opts.each do |opt|
              header << @lookandfeel.lookup(opt)
            end
          end
          header
        end

        def to_csv(keys, symbol = :active_packages, target = :atc_class)
          result = []
          eans = {}
          index = 0
          lang = @lookandfeel.language
          case target
          when :division
            result.push(header(keys))
            index += 1
            @model.each { |seq|
              seq.packages.values.each { |pack|
                line = keys.collect { |key|
                  if respond_to?(key)
                    send(key, pack)
                  else
                    pack.send(key)
                  end
                }
                result.push(line)
                index += 1
              }
            }
            @total = index - 1
          when :fachinfo_chapter
            opts = @model.first[:chapters].collect { |c| "fi_#{c[:chapter]}" }.uniq
            result.push(header(keys, opts))
            index += 1
            @model.each { |model|
              line = keys.collect do |key|
                if model[:package].respond_to?(key)
                  model[:package].send(key).to_s
                end
              end
              model[:chapters].each do |chapter|
                line << chapter[:matched]
              end
              result.push(line)
              index += 1
            }
            @total = index - 1
          when :flickr_photo
            result.push(header(keys))
            index += 1
            @_counted = {} # for reg and seq
            @model.each { |pack|
              line = keys.collect { |key|
                value = pack.send(key)
                uniq_key = (key == :seqnr) ? pack.iksnr + value : value
                unless @_counted[uniq_key]
                  @_counted[uniq_key] = true
                  @flickr_photos[key.to_s] += 1
                end
                value
              }
              result.push(line)
              index += 1
            }
            @total = index - 1
          when :atc_class
            result.push(header(keys))
            index += 1
            @model.each do |atc|
              result.push(["#MGrp", atc.code.to_s, atc.description(lang).to_s])
              index += 1
              # Rule:
              # For the CSV Exporter only export the Product with the longer ATC-Code.
              # We export the product with the ATC-Code that has more digits
              atc.send(symbol).each do |pack|
                next unless pack
                if eans[pack.ikskey].nil?
                  eans[pack.ikskey] = {cnt: 0}
                end
                eans[pack.ikskey][:cnt] += 1
                atc_code = atc.code.to_s
                if eans[pack.ikskey][:cnt] > 1
                  if eans[pack.ikskey][:atc].length < atc_code.length
                    result[eans[pack.ikskey][:idx]] = nil # delete
                  else
                    next # skip pack
                  end
                end
                eans[pack.ikskey][:atc] = atc_code
                eans[pack.ikskey][:idx] = index
                key = nil
                begin
                  line = keys.collect do |key|
                    if respond_to?(key)
                      send(key, pack)
                    else
                      pack.send(key)
                    end
                  end
                  result.push(line)
                rescue
                  result.push ["error collecting #{key} for ean code=" + pack.barcode.to_s]
                end
                index += 1
              end
            end
          else
            puts "unexpected target #{target}"
          end
          res = result.compact.collect { |line|
            CSV.generate_line(line, col_sep: ";").encode("utf-8", invalid: :replace, undef: :replace, replace: "")
          }
          res.join("")
        end

        def to_csv_file(keys, path, symbol = :active_packages, target = :atc_class)
          FileUtils.makedirs(File.dirname(path))
          File.open(path, "w") do |fh|
            fh.puts to_csv(keys, symbol, target)
          end
        end

        def vaccine(pack)
          boolean(pack.vaccine)
        end
      end
    end
  end
end
