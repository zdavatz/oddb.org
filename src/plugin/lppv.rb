#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::LppvPlugin -- oddb.org -- 10.05.2012 -- yasaka@ywesee.com
# ODDB::LppvPlugin -- oddb.org -- 10.02.2012 -- mhatakeyama@ywesee.com
# ODDB::LppvPlugin -- oddb.org -- 18.01.2006 -- sfrischknecht@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))

require "plugin/plugin"
require 'model/package'
require "util/html_parser"
require "net/http"

module ODDB 
	class LppvWriter < NullWriter
		def initialize
			super
			@tables = []
		end
		def new_tablehandler(table)
			if(table)
				@tables.push(table) unless(@tables.include?(table))
			end
			@table = table
		end
    def eans
      eans = []
      pcode_style = /[0-9]{6,8}/u
      ean_style = /[0-9]{13}/u
      @tables.at(1).each_row { |row|
        if(pcode_style.match(row.cdata(3)) \
           && ean_style.match(row.cdata(5)))
          eans << row.cdata(5).to_i.to_s
        end
      }
      eans
    end
		def send_flowing_data(data)
			if(@table)
				@table.send_cdata(data)	
			end
		end
	end
	class LppvPlugin < Plugin
		LPPV_HOST = 'www.lppa.ch'
		LPPV_PATH = '/index/%s.htm'
		attr_reader :updated_packages
		def initialize(app)
			super
			@updated_packages = []
			@packages_with_sl_entry = []
			@not_updated_chars = []
		end
    def update(range = 'A'..'Z')
      @eans = []
      Net::HTTP.new(LPPV_HOST).start { |http|
        range.each { |char|
          eans = get_eans(char, http)
          @eans << eans
        }
      }
      update_packages(@eans.dup.flatten)
    end
    def get_eans(char, http)
      writer = LppvWriter.new
      path = sprintf(LPPV_PATH, char)
      response = http.get(path)
      formatter = HtmlFormatter.new(writer)
      parser = HtmlParser.new(formatter)
      parser.feed(response.body)
      if writer.eans.empty?
        @not_updated_chars.push(char)
      end
      origin = "http://#{LPPV_HOST}#{path}"
      writer.eans
    end
    def update_package(package, data)
      if(ean = data.delete(package.barcode))
        if(package.sl_entry && package.price_public)
          @packages_with_sl_entry.push(package)
        else
          do_lppv_update(package)
        end
      elsif(package.lppv && package.data_origin(:lppv) == :lppv)
        @app.update(package.pointer, {:lppv => false}, :lppv)
      end
    end
		def update_packages(data)
			@app.each_package { |package| 
				update_package(package, data)
			}
		end
    def report
      lines = [
        "Updated Packages (lppv flag true): #{@updated_packages.size}",
        nil,
        "Packages with SL-Entry: #{@packages_with_sl_entry.size}",
        nil,
        "Not updated were: #{@not_updated_chars.join(', ')}",
      ]
      lines.flatten.join("\n")
    end
    def do_lppv_update(package)
      if(!package.lppv)
        args = {
          :lppv => true
        }
        @app.update(package.pointer, args, :lppv)
        @updated_packages.push(package)
      end
    end
	end
end
