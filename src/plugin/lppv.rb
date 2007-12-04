#!/usr/bin/env ruby
# LppvPlugin -- oddb.org -- 18.01.2006 -- sfrischknecht@ywesee.com

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
		def prices
			prices = {}
			pcode_style = /[0-9]{6,8}/
			price_style = /\d+\.\d\d/
			@tables.at(1).each_row { |row|
				if(pcode_style.match(row.cdata(3)) \
					 && price_style.match(row.cdata(5)))
					prices.store(row.cdata(3), row.cdata(5))
				end
			}
			prices
		end
		def send_flowing_data(data)
			if(@table)
				@table.send_cdata(data)	
			end
		end
	end
	class LppvPlugin < Plugin
		class PriceUpdate
			attr_reader :old, :current, :package
			def initialize(package, current)
				old = package.price_public
				if old == nil
					@old = 0
				else
					@old = old
				end
				@current = Package.price_internal(current, :public)
				@package = package
			end
			def up?
				@current > @old
			end	
			def down?
				@current < @old
			end
			def changed?
				@current != @old
			end
			def resolve_link(model)
				pointer = model.pointer
				str = 'http://ch.oddb.org/de/gcc/resolve/pointer/'.concat(CGI.escape(pointer.to_s))
			end
			def report_lines
				[
					resolve_link(package),
					sprintf("%-20s  %-20.2f  %-20.2f %s", @package.iksnr, 
									@old.to_f/100, @current.to_f/100, @package.name),
									nil,
				]
			end
		end
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
			@prices = {}
			Net::HTTP.new(LPPV_HOST).start { |http| 
				range.each { |char| 
					@prices.update(get_prices(char, http))
				}
			}
			update_packages(@prices.dup)
		end
		def get_prices(char, http)
			writer = LppvWriter.new
			response = http.get(sprintf(LPPV_PATH, char))
			formatter = HtmlFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(response.body)
			if writer.prices.empty?
				@not_updated_chars.push(char)
			end
			writer.prices
		end				
		def update_package(package, data)
			if(price_dat = data.delete(package.pharmacode))
				if(package.sl_entry && package.price_public)
					@packages_with_sl_entry.push(package)
				else
					do_price_update(package, price_dat)
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
			ups, downs = @updated_packages.sort_by { |price| 
				price.package.name }.partition { |price| price.up? } 
				lines = [
					"Downloaded Prices: #{@prices.size}",
					"Updated Packages: #{@updated_packages.size}",
					nil,
					"Packages with SL-Entry: #{@packages_with_sl_entry.size}",
					nil,
					"The following Packages experienced a Price RAISE:",
					sprintf("%-20s  %-20s  %-20s %-s", 
									"IKS-Number", "Old Price", "New Price", "Package Name"),
				]
				ups.each { |price| lines.concat(price.report_lines) }
				lines.concat([ nil,
					"The following Packages experienced a Price CUT:",
					sprintf("%-20s  %-20s  %-20s %-s,", 
									"IKS-Number", "Old Price", "New Price", "Package Name"),
				])
				downs.each { |price| lines.concat(price.report_lines) }
				lines.push("Not updated were: " << @not_updated_chars.join(', '))
				lines.flatten.join("\n")
		end
		def	do_price_update(package, price)
			price_obj = PriceUpdate.new(package, price)
			if(price_obj.changed? || !package.lppv)
				args = {
					:price_public => price,
					:lppv					=> true,
				}
				@app.update(package.pointer, args, :lppv)
				@updated_packages.push(price_obj)
			end
		end
	end
end
