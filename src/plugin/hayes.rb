#!/usr/bin/env ruby
# HayesPlugin -- oddb -- 25.02.2004 -- mhuggler@ywesee.com

require 'plugin/interaction'
require 'util/html_parser'
require 'model/text'

module ODDB
	module Interaction
		class HayesWriter < NullWriter
			def initialize
				@tablehandlers = []
				@substances = []
				@cytochromes = {}
			end
			def check_cytochrome(cyt)
				cytochromes = []
=begin
				if(cyt.match(/-/))
					arr = cyt.split("-")
					start = arr.first[-1,1].to_i
					stop = arr.last.to_i
					(start..stop).each { |digit|
						cytochromes.push(arr.first.chop << digit.to_s)
					}
				else
					cytochromes.push(cyt)
				end
=end
				cytochromes.push(cyt)
				cytochromes
			end
			def check_string(string)
				case string
				when "\240"
					return false
				when [] 
					return false
				when ""
					return false
				when nil
					return false
				else
					return true
				end
			end
			def create_connection(name, function)
				case function
				when 'substrate'
					new_class = ODDB::Interaction::SubstrateConnection
				when 'inhibits'
					new_class = ODDB::Interaction::InhibitorConnection
				when 'induces'
					new_class = ODDB::Interaction::InducerConnection
				end
				new_class.new(name, 'en')
			end
			def extract_data
				parse_substances
				@cytochromes
			end
			def handle_cytochrome(cytochrome_arr, conn)
				cytochrome_arr.each { |cytochrome|
					unless(@cytochromes.has_key?(cytochrome))
						@cytochromes.store(cytochrome, ODDB::Interaction::Cytochrome.new(cytochrome))
					end
					@cytochromes[cytochrome].add_connection(conn)
				}
			end
			def handle_functions(row_one, row_two)
				cyts = []
				if(check_string(row_one))
					if(@function)
						cyts.push(handle_row(row_one, @function))
					elsif(@function_one)
						cyts.push(handle_row(row_one, @function_one))
					end
				end
				if(check_string(row_two))
					cyts.push(handle_row(row_two, @function_two))
				end
				handle_substance(@current_substance, cyts)
			end
			def handle_row(row, function)
				cyts = {}
				if(row.is_a?(Array))
					row.each { |rw|
						cyts.store(rw,function)		
					}
				else
					cyts.store(row, function)
				end
				cyts
			end
			def handle_substance(substance, cytochromes)
				cytochromes.each { |hsh|
					hsh.each { |cyt, function|
						conn = create_connection(substance, function)
						handle_cytochrome(check_cytochrome(cyt), conn)
					}
				}
			end
			def new_fonthandler(handler)
				if(handler!=nil \
					&& (handler.attribute('color')=='Blue' \
					|| handler.attribute('color')=='#000080'))
					 @category = "start"
				 else
					 @category = nil 
				end
			end
			def new_tablehandler(handler)
				@current_tablehandler = handler
				@tablehandlers.push(handler)
			end
			def parse_substances
				@parsing = nil
				@tablehandlers.each { |th|
					unless(th.nil?)
						th.each_row { |row|
							if(!row.cdata(0).is_a?(Array) \
								&& @parsing=="start" \
								&& check_string(row.cdata(0)))
								@current_substance = row.cdata(0)
								handle_functions(row.cdata(1), row.cdata(2))
							elsif(@parsing=="start")
								handle_functions(row.cdata(1), row.cdata(2))
							end
							unless(@function_set)
								if(!row.cdata(0).is_a?(Array) \
									&& row.cdata(0).match(/>>>>/))
									if(row.cdata(0).match(/Substrate/))
										arr = row.cdata(0).split(/>>>>/)
										@function = arr.first.downcase
									elsif(row.cdata(0).match(/DRUG/))
										arr_one = row.cdata(1).split(/>>>>/)
										arr_two = row.cdata(2).split(/>>>>/)
										@function_one = arr_one.first.downcase
										@function_two = arr_two.first.downcase
									end
									@function_set = true
									@parsing = "start"
								end
							end
						}
					end
				}
			end
			def send_flowing_data(data) 
				unless(@current_tablehandler.nil?)
					if(@category=="start")
						@current_tablehandler.send_cdata(data << ">>>>")
					else
						@current_tablehandler.send_cdata(data)
					end
				end
			end
			def send_line_break
				unless(@current_tablehandler.nil?)
					@current_tablehandler.next_line
				end
			end
		end
		class HayesPlugin < Plugin
			HTTP_SERVER = 'www.edhayes.com'
			HTML_PATH = ''
			TARGET = File.expand_path('../../data/html/interaction/hayes', File.dirname(__FILE__))
			TABLES = {
				:substrate		=> "CYP450-1.html",
				:interaction	=> "CYP450-2.html",
			}
			RETRIES = 3
			RETRY_WAIT = 5
			def initialize(app)
				@app = app
			end
			def fetch_pages
				TABLES.each { |key, value|
					path = [HTML_PATH, value].join("/")
					target = [TARGET, value].join("/")
					http_file(HTTP_SERVER, path, target)
				}
			end
			def parse_substrate_table
				writer = HayesWriter.new
				formatter = HtmlFormatter.new(writer)
				parser = HtmlParser.new(formatter)
				file = [TARGET, TABLES[:substrate]].join("/")
				html = File.read(file)
				parser.feed(html)
				writer.extract_data
			end
			def parse_interaction_table
				writer = HayesWriter.new
				formatter = HtmlFormatter.new(writer)
				parser = HtmlParser.new(formatter)
				file = [TARGET, TABLES[:interaction]].join("/")
				html = File.read(file)
				parser.feed(html)
				writer.extract_data
			end
		end
	end
end
