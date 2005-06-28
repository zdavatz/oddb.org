#!/usr/bin/env ruby
# -- oddb -- 17.06.2005 -- jlang@ywesee.com

require 'net/http'
require 'util/html_parser'
require 'plugin/plugin'

module ODDB
	class FXCrossratePlugin < Plugin
		class Writer < NullWriter
			attr_reader :tablehandlers
			def initialize(an_io = $stdout)
				@tablehandlers = []
				@out = an_io
			end
			def send_flowing_data(data)
				#puts"send_flowing_data(#{data})"
				if(@table)
					@table.send_cdata(data)
				end
			end
			def send_line_break
				@out << "\n"
			end
			def new_tablehandler(handler)
				if(@table = handler)
					@tablehandlers.push(handler)
				end
			end
		end
		def update
			writer = Writer.new
			formatter = HtmlFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			rates = parse(getpage())
			rates.each { |symbol, value|
				@app.set_currency_rate(symbol, value)
			}
			@app.odba_store
		end
		def parse(html)
			unless(html.nil?)
				writer = Writer.new
				formatter = HtmlFormatter.new(writer)
				parser = HtmlParser.new(formatter)
				parser.feed(html)	
				data = writer.tablehandlers.select { |handler|
					/^currency/i.match(handler.cdata(0,0))
				}.first
				{'EUR' => data.cdata(2,1).to_f, 'USD' => data.cdata(2,3).to_f}
			end
		end
		def getpage
			begin
				Net::HTTP.start('www.oanda.com') { |conn|
					response = conn.get('/cgi/crossrate/crossrateresult.shtml?quotes=EUR&quotes=CHF&quotes=USD&go=Get+my+Table+++')
					response.body
				}
			rescue SocketError
				puts "no connection..."
			end
		end
	end
end
