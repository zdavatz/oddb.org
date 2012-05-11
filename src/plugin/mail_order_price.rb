#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::MailOrderPricePlugin -- oddb.org -- 11.05.2012 -- yasaka@ywesee.com
# ODDB::MailOrderPricePlugin -- oddb.org -- 23.02.2012 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'plugin/plugin'
require 'model/package'

module ODDB
	class MailOrderPricePlugin < Plugin
    CSV_DIR  = File.expand_path('../../data/csv', File.dirname(__FILE__))
    def report
      lines = [
        "Updated Packages: #{@updated_packages.length}",
        "Deleted Packages: #{@deleted_packages.length}"
      ]
      lines.join("\n")
    end
    def update(csv_file_path)
      unless File.exist?(csv_file_path)
        if File.exist?(File.join(CSV_DIR, csv_file_path))
          csv_file_path = File.join(CSV_DIR, csv_file_path)
        end
      end
      if File.exist?(csv_file_path)
        # import price 
        @updated_packages = []
        File.readlines(csv_file_path).each do |line|
          if x = line.split(/;/) and x.length == 3 and x[0][0,4] == '7680'
            iksnr = x[0][4,5]
            ikscd = x[0][9,3]
            if reg = @app.registration(iksnr) and pac = reg.package(ikscd)
              price = x[1]
              url   = x[2].chomp
              if pac.mail_order_prices and index = pac.mail_order_prices.index { |price| price.url == url }
                pac.update_mail_order_price(index, price, url)
              else
                pac.insert_mail_order_price(price, url)
              end
              @updated_packages << pac.pharmacode
            end
          end
        end
        # delete price
        @deleted_packages = []
        @app.each_package do |pac|
          next if pac.mail_order_prices.nil?
          unless pac.mail_order_prices.empty? or @updated_packages.include?(pac.pharmacode)
            pac.delete_all_mail_order_prices
            @deleted_packages << pac.pharmacode
          end
        end
      end
    end
	end
end
