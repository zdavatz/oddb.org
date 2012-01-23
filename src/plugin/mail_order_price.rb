#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::MailOrderPricePlugin -- oddb.org -- 23.01.2012 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'plugin/plugin'
require 'model/package'
require 'fileutils'

module ODDB
	class MailOrderPricePlugin < Plugin
    LOGO_PATH = File.expand_path('../../doc/resources/logos', File.dirname(__FILE__))
		def initialize(app)
			super(app)
		end
    def report
      "Updated Packages: #{@updated_packages}"
    end
    def update(csv_file_path, logo_file_path)
      unless File.exist?(logo_file_path)
       if File.exist?(File.join(LOGO_PATH, logo_file_path))
         logo_file_path = File.join(LOGO_PATH, logo_file_path) 
       end
      end
      if File.exist?(csv_file_path) and File.exist?(logo_file_path)
        # copy logo file
        unless File.exist?(File.join(LOGO_PATH, File.basename(logo_file_path)))
          FileUtils.cp(logo_file_path, File.join(LOGO_PATH, File.basename(logo_file_path)))
        end
        logo_file_name = File.basename(logo_file_path)

        # import price 
        @updated_packages = 0
        File.readlines(csv_file_path).each do |line|
          if x = line.split(/;/) and x.length == 3 and x[0][0,4] == '7680'
            iksnr = x[0][4,5]
            ikscd = x[0][9,3]
            if reg = @app.registration(iksnr) and pac = reg.package(ikscd)
              price = x[1]
              url   = x[2].chomp
              if pac.mail_order_prices 
                if index = pac.mail_order_prices.index{|price| price.logo == logo_file_name}
                  pac.update_mail_order_price(index, price, url, logo_file_name)
                else
                  pac.add_mail_order_price(price, url, logo_file_name)
                end
                @updated_packages += 1
              end
            end
          end
        end
      end
    end
	end
end
