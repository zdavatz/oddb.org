#!/usr/bin/env ruby

# ODDB::OdbaExporter::CsvExporter -- oddb.org -- 28.12.2011 -- mhatakeyama@ywesee.com
# ODDB::OdbaExporter::CsvExporter -- oddb.org -- 26.08.2005 -- hwyss@ywesee.com

require "csv"

module ODDB
  module OdbaExporter
    module CsvExporter
      DOCTOR = [:ean13, :exam, :salutation, :title, :firstname,
        :name, :praxis, :first_address_data, :email, :language,
        :specialities]
      ADDRESS = [:type, :name, :additional_lines, :address,
        :plz, :city, :canton, :fon, :fax]
      DEFR = [:de, :fr]
      DEFRIT = [:de, :fr, :it]
      INDEX_THERAPEUTICUS = [:code, :defr, :idx_th_comment, :idx_th_limitation]
      MIGEL = [:migel_code, :migel_subgroup, :product_code,
        :migel_product_text, :accessory_code, :defrit,
        :migel_limitation, :format_price, :qty, :migel_unit,
        :limitation, :format_date]
      MIGEL_SUBGROUP = [:migel_group, :code, :defrit,
        :migel_limitation]
      MIGEL_GROUP = [:code, :defrit, :migel_limitation]
      NARCOTIC = [:casrn, :swissmedic_code, :narc_substance,
        :category, :narc_reservation_text]
      PRICE_HISTORY = [:iksnr, :ikscd, :name, :size, :barcode, :pharmacode,
        :out_of_trade, :price_history]
      PRICE_POINT = [:amount, :authority, :origin]
      def self.address_data(item, opts = {})
        collect_data(ADDRESS, item)
      end

      def self.collect_data(keys, item, opts = {})
        keys.collect { |key|
          if item.nil?
            ""
          elsif item.respond_to?(key)
            val = item.send(key)
            if val.is_a?(Array)
              val = val.join(",")
            end
            val.to_s.tr("\n", "\v")
          else
            send(key, item, opts)
          end
        }
      end

      def self.collect_languages(keys, item, opts = {})
        descr = if item.respond_to?(:descriptions)
          item.descriptions
        else
          {}
        end
        keys.collect { |key|
          descr.fetch(key.to_s, "").to_s.force_encoding("utf-8").gsub(/\r?\n/u, " / ")
        }
      end

      def self.defr(item, opts = {})
        collect_languages(DEFR, item)
      end

      def self.defrit(item, opts = {})
        collect_languages(DEFRIT, item)
      end

      def self.dump(keys, item, fh, opts = {})
        CSV.open(fh.path, "a+", col_sep: ";", encoding: "UTF-8") { |csv|
          csv << collect_data(keys, item, opts).flatten
        }
      end

      def self.first_address_data(item, opts = {})
        addr = item.praxis_address || item.address(0)
        address_data(addr)
      end

      def self.format_date(item, opts = {})
        if (date = item.date)
          date.strftime("%d.%m.%Y")
        else
          ""
        end
      end

      def self.format_price(item, opts = {})
        item.price = item.price / 100.0
        item.price = sprintf("%.2f", item.price)
      end

      def self.idx_th_limitation(item, opts = {})
        defr(item.limitation_text)
      end

      def self.idx_th_comment(item, opts = {})
        defr(item.comment)
      end

      def self.migel_limitation(item, opts = {})
        defrit(item.limitation_text)
      end

      def self.migel_group(item, opts = {})
        collect_data(MIGEL_GROUP, item.group)
      end

      def self.migel_product_text(item, opts = {})
        defrit(item.product_text)
      end

      def self.migel_subgroup(item, opts = {})
        collect_data(MIGEL_SUBGROUP, item.subgroup)
      end

      def self.migel_unit(item, opts = {})
        defrit(item.unit)
      end

      def self.narc_reservation_text(item, opts = {})
        defr(item.reservation_text)
      end

      def self.narc_substance(item, opts = {})
        defr(item.substance)
      end

      def self.out_of_trade(item, opts = {})
        !!(item.out_of_trade if item.respond_to?(:out_of_trade))
      end

      def self.price_history(item, opts = {})
        if dates = opts[:dates]
          dates.inject([]) do |memo, date|
            memo.concat price_point(item, date, :exfactory)
            memo.concat price_point(item, date, :public)
          end
        end
      end

      def self.price_point(item, date, type)
        price = (prices = item.prices[type]) \
          && prices.find do |price|
               if valid_from = price.valid_from
                 valid_from.to_date == date
               else
                 date.nil?
               end
             end
        collect_data(PRICE_POINT, price)
      end
    end
  end
end
