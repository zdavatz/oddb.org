#!/usr/bin/env ruby
# FlockhartPlugin -- oddb -- 25.02.2004 -- maege@ywesee.com

require 'plugin/interaction'
require 'util/html_parser'
require 'model/text'

module ODDB
	module Interaction
		class FlockhartWriter < NullWriter
			attr_reader :substances
			def initialize
				@tablehandlers = []
				@cytochromes = {}
				@values = {}
				@collected_hashes = []
				@duplicates = []
			end
			def check_string(string)
					case string
				when /\240/
					return false
				when /^=/
					return false
				when /^>/
					return false
				when /^[0-9]OH/
					return false
				when /^[0-9]-OH/
					return false
				when /^NOT/
					return false
				when /^NAPQI/
					return false
				when ""
					return false
				else
					return true
				end
			end
			def clear_string(string)
				string.delete!("\240")
				string.slice!(/^=/)
				string.slice!(/^>/)
				string.slice!(/[0-9]OH/)
				string.slice!(/[0-9]-OH/)
				string.strip
				end	
			def create_update_objects(base_name, cat, cyt_id, not_cyt)
				case @type
				when 'substrates'
					new_class = ODDB::Interaction::SubstrateConnection
				when 'inhibitors'
					new_class = ODDB::Interaction::InhibitorConnection
				when 'inducers'
					new_class = ODDB::Interaction::InducerConnection
					end
				obj = new_class.new(base_name, 'en')
				obj.category = cat unless cat.nil?
				@cytochromes.each { |key, value|
					column = key.split("/").first
					base_name = key.split("/")[1]
					if(column==cyt_id.to_s)
						value.add_connection(obj) unless not_cyt==base_name
					end
				}		
				end
			def end_category 
				@category = "end" unless @current_category.nil?
			end	
			def	extract_data
				links = ODDB::Interaction::FlockhartPlugin::LINKS
				max = links.size
				@tablehandlers.compact.each { |th|
					th.each_row { |row|
						(0...max).each { |dig|
							data = row.cdata(dig)
							if(data.is_a?(String))
								if(data.match(/@\/@\/@/))
									parse_cyt_string(data, dig)
								elsif(data.size>3)
									@collected_hashes.push(Hash[dig, parse_string(data)])
								end
							end
							if(data.is_a?(Array))
								data.each { |str|
									@collected_hashes.push(Hash[dig, parse_string(str)])
								}
							end
						}
						@collected_hashes.each { |hash|
							hash.each { |cyt_id, hsh|
								if(hsh!=nil)
									hsh.each { |base_name, cat|
										not_cyt = nil
										if(base_name.match(/-\/-\/-/))
											arr = base_name.split(/-\/-\/-/)
											base_name = arr.first
											not_cyt = arr[1]
										end
										create_update_objects(base_name, cat, cyt_id, not_cyt)
									}
								end
							}
						}
						@collected_hashes.clear
					}
				}
				@cytochromes
			end
			def new_fonthandler(handler)
				if(handler!=nil && (handler.attribute('color')=='red' || handler.attribute('color')=='#FF0000') )
					@current_category = nil
					@category = "start"
				else
					@category = nil 
				end
			end
			def new_tablehandler(handler)
				@current_tablehandler = handler
				@tablehandlers.push(handler)
			end	
			def parse_array(array)
				hsh = {}
				array.each { |str| 
					if(arr=str.split(/\*\/\*\/\*/))
						arr[1] = nil if arr[1].match(/nil/)
						(0...(arr.size/2)).each { |dig|
							hsh.store(arr.shift, arr.shift)
						}
					end
				}
				hsh
			end
			def parse_cyt_string(string, cyt_id)
				array = string.split(/@\/@\/@/)
				cyt = []
				if(FlockhartPlugin::FORMAT_CYT_ID.keys.include?(array[1]))
					FlockhartPlugin::FORMAT_CYT_ID[array[1]].each { |name|
						cyt.push(name)
					}
				else
					cyt = array[1]
				end
				objs = {}
				cyt.each { |name|
					objs.store(cyt_id.to_s+"/"+name, ODDB::Interaction::Cytochrome.new(name))
				}
				objs.each { |id, obj|
					unless(@cytochromes.keys.include?(id))
						@cytochromes.store(id, obj)
					end
				}
				@type = array.first
			end
			def parse_string(string)
				array = []
				if(string.match(/-\/-\/-/))
					array = string.split(/&\/&\/&/)
					@duplicates.push(array.shift)
				else
					array = string.split(/&\/&\/&/)
				end
				parse_array(array)
			end
			def send_flowing_data(data) 
				unless(@current_tablehandler.nil?)
					unless(@current_table.nil?)
						@data = data
						case @category
						when "start"
							@current_category = data.split(/:/).first.downcase.strip 
							@data = 'cat'
						when "end"
							@current_category = nil
							@category = nil
						end
						if(@tr_class && @tr_class.match(/lite/) && @data!='cat')
							data = clear_string(data)
							return unless check_string(data)
							if(data.match(/\(not/))
								data.slice!(/\(not/)
								data.slice!(/\)/)
								data = @previous_data << "-/-/-" + data.strip
							end
							if(@ignore_next && !data.match(/=/))
								@ignore_next = false
							else
								if(data.match(/=/))
									data.slice!(/=/)
									@ignore_next = true
								end
								data_string = write_substance_string(data)
								@previous_data = data
								@current_tablehandler.send_cdata(data_string) if check_string(data_string)
							end
						elsif(@tr_class && @tr_class.match(/green/) && @data!='cat')
							type = @current_table.dup
							type_cyt = type << "@/@/@" << data.strip
							@current_tablehandler.send_cdata(type_cyt) if check_string(type_cyt)
						end
					end
				end
			end
			def send_image(src)
				@current_table = nil
				ODDB::Interaction::FlockhartPlugin::IMAGES.each { |img|
					if(src.match(/#{img}/))
						@current_table = src.split(/\./).first.downcase
					end
				}
			end
			def send_line_break
				unless(@current_tablehandler.nil?)
					@current_tablehandler.next_line
				end
			end
			def start_tr(attributes)
				if(attributes && attributes.first)
					@tr_class = attributes.first[1]
				end
			end
			def write_substance_string(data)
				cat = @current_category
				name = data.strip
				string = "#{name}" 
				if(cat)
					string << "*/*/*#{cat}"
				else
					string << "*/*/*nil"
				end
				string << "&/&/&"
			end
		end
		class DetailWriter < NullWriter
			def initialize(name)
				@cytochrome = Cytochrome.new(name.split(".").pop)
			end
			def extract_data
				@cytochrome
			end
			def new_linkhandler(handler)
				if(handler && handler.attributes["href"])
					if((href=handler.attributes["href"]).match(/Abstract/))
						@current_link = href
					end
				end
			end
			def new_font(font)
				if(font!=nil && font[2]==1)
					@bold_font = "start"
				elsif(font!=nil && font[1]==1)
					@italic_font = "start"
				else
					@bold_font = "stop"
					@italic_font = "stop"
				end
			end
			def send_image(src)
				ODDB::Interaction::FlockhartPlugin::IMAGES.each { |img|
					if(src.match(/#{img}/))
						@current_table = src.split(/\./).first.downcase
					end
				}
			end
			def send_flowing_data(data) 
				unless(@current_table.nil?)
					if(@bold_font=="start" && data.size>3)
						name = data.delete(":").downcase
						case @current_table
						when /substrates/
							new_class = ODDB::Interaction::SubstrateConnection
						when /inhibitors/
							new_class = ODDB::Interaction::InhibitorConnection
						when /inducers/
							new_class = ODDB::Interaction::InducerConnection
						end
						@connection = new_class.new(name, 'en')
						@cytochrome.add_connection(@connection)
					end
					if(@italic_font=="start" && data!="PubMed")
						@abstractlink = ODDB::Interaction::AbstractLink.new
						@abstractlink.info = data
						@connection.add_link(@abstractlink)
					end
					if(@current_link && @abstractlink)
						@abstractlink.href = @current_link
						@abstractlink.text = data
						@current_link = nil
					end
				end
			end
			def start_tr(attrs)
			end
		end
		class TableLinksWriter < NullWriter
			attr_reader :links
			def initialize
				@links = []
			end
			def extract_data
			end
			def new_linkhandler(handler)
				unless(handler.nil?)
					link = handler.attribute('href')
					valid_link = link.split(/#/)[0]
					if(valid_link!=nil && valid_link.match(/.htm/))
						@links.push(valid_link) unless @links.include?(valid_link) || ODDB::Interaction::FlockhartPlugin::INVALID_LINKS.include?(valid_link)
					end
				end
			end
			def start_tr(attrs)
			end
		end
		class FlockhartPlugin < Plugin
			HTTP_SERVER = 'medicine.iupui.edu'
			HTML_PATH = '/flockhart'
			TARGET = File.expand_path('../../data/html/interaction/flockhart', File.dirname(__FILE__))
			TABLE = "table.htm"
			LINKS = [
				"1A2.htm",
				"2B6.htm",
				"2C8.htm",
				"2C19.htm",
				"2C9.htm",
				"2D6.htm",
				"2E1.htm",
				"3A457.htm",
			]
			FORMAT_CYT_ID = {
				"3A457"		=>	["3A4", "3A5-7"],
				"3A4,5,7"	=>	["3A4", "3A5-7"],
			}
			INVALID_LINKS = [ "clinlist.htm" ]
			RETRIES = 3
			RETRY_WAIT = 5
			IMAGES = ["substrates", "inhibitors", "inducers"]
			def initialize(app, refetch_pages)
				@app = app
				@refetch_pages = refetch_pages
				@parsing_errors = {}
			end
			def fetch_page(page_name)
				path = [HTML_PATH, page_name].join("/")
				target = [TARGET, page_name].join("/")
				file = http_file(HTTP_SERVER, path, target)	
				file
			end
			def parse_detail_pages
				links = get_table_links
				cytochromes = {}
				links.each { |link|
					if(@refetch_pages)
						fetch_page(link)
					end
					cyt_name = link.split(".").first
					file_path = [TARGET, link].join("/")
					writer = DetailWriter.new(cyt_name)
					formatter = Formatter.new(writer)
					parser = Parser.new(formatter)
					html = File.read(file_path)
					parser.feed(html)
					if(FORMAT_CYT_ID.keys.include?(cyt_name))
						FORMAT_CYT_ID[cyt_name].each { |name|
							cytochromes.store(name, writer.extract_data)
						}
					else
						cytochromes.store(cyt_name, writer.extract_data)
					end
				}
=begin
				cytochromes.each { |cyt|
					puts "cyt_name: #{cyt.cyt_name}"
					puts "substrate: #{cyt.substrates.size}"
					puts "inhibitor: #{cyt.inhibitors.size}"
					puts "inducers: #{cyt.inducers.size}"
				}
				puts "cytochromes: #{cytochromes.size}"
=end
				cytochromes
			end
			def get_table_links
				writer = TableLinksWriter.new
				formatter = Formatter.new(writer)
				parser = Parser.new(formatter)
				file = [TARGET, TABLE].join("/")
				html = File.read(file)
				parser.feed(html)
				writer.extract_data
				if(writer.links.size != LINKS.size)
					@parsing_errors.store("flockhart", 'different amount of links found in table.htm')
				end
				writer.links
			end
			def parse_table
				if(@refetch_pages)
					fetch_page(TABLE)
				end
				writer = FlockhartWriter.new
				formatter = Formatter.new(writer)
				parser = Parser.new(formatter)
				file = [TARGET, TABLE].join("/")
				html = File.read(file)
				html.gsub!('<br><br>', '<category />')
				parser.feed(html)
				result = {} 
				writer.extract_data.each { |key, value|
					result.store(key.split("/").pop, value)
				}	
				result
			end
			def report
				errors = []
				unless(@parsing_errors.empty?)
					@parsing_errors.to_a.each { |error|
						errors << error.join(" => ")	
					}
				end
				lines = [
					"updated packages: #{@updated_packages.size}",
					"parsing errors:   #{@parsing_errors.size}",
				] + errors.sort
				lines.join("\n")
			end
		end
	end
end
