#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Interaction::FlockhartPlugin -- oddb.org -- 09.01.2012 -- mhatakeyama@ywesee.com
# ODDB::Interaction::FlockhartPlugin -- oddb.org -- 25.02.2004 -- mhuggler@ywesee.com

require 'plugin/interaction'
require 'util/html_parser'
require 'model/text'
require 'model/cyp450'
require 'model/cyp450connection'
require 'mechanize'

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
				when '', /\302\240/u, /^[=>(:]/u, /^[0-9]OH/u, /^[0-9]-OH/u, /^No[rt]/iu,
             /^NAPQI/u, /^[0-9]+\s*$/u, /^Chr\d+\s*$/u,
             /o-desme/iu
					return false
				else
					return true
				end
			end
			def clear_string(string)
				string.delete!("\302\240")
				string.slice!(/^=/u)
				string.slice!(/^>/u)
				string.slice!(/[0-9]OH/u)
				string.slice!(/[0-9]-OH/u)
				string.strip
      end
			def create_update_objects(base_name, data, cyt_id, not_cyt)
				case @type
				when 'substrates'
					new_class = ODDB::Interaction::SubstrateConnection
				when 'inhibitors'
					new_class = ODDB::Interaction::InhibitorConnection
				when 'inducers'
					new_class = ODDB::Interaction::InducerConnection
        end
				obj = new_class.new(base_name, 'en')
        data.each { |key, val|
          obj.send("#{key}=", val) if(val)
        }
				@cytochromes.each { |key, value|
					column, base_name = key.split("/")
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
				@tablehandlers.compact.uniq.each { |th|
					th.each_row { |row|
						(0...max).each { |dig|
							data = row.cdata(dig)
							if(data.is_a?(String))
								if(data.match(/@\/@\/@/u))
                  # clean out some javascript.
                  data.gsub!(/^.*function[^}]+\}/u, '')
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
									hsh.each { |base_name, data|
										not_cyt = nil
										if(base_name.match(/-\/-\/-/u))
											base_name, not_cyt = base_name.split(/-\/-\/-/u)
										end
										create_update_objects(base_name, data, cyt_id, not_cyt)
									}
								end
							}
						}
						@collected_hashes.clear
					}
				}
				@cytochromes
			end
      def new_font(font)
        _, _, bold, _ = font
        if bold == 1
					@current_category = nil
					@category = "start"
        else
					@category = nil 
        end
      end
			def new_tablehandler(handler)
        @current_table = nil
				@current_tablehandler = handler
				@tablehandlers.push(handler)
			end	
			def parse_array(array)
				hsh = {}
				array.each { |str| 
					name, category, auc = str.split(/\*\/\*\/\*/u)
          hsh.store(name, {:category => category, :auc_factor => auc})
				}
				hsh
			end
			def parse_cyt_string(string, cyt_id)
				array = string.split(/@\/@\/@/u)
				cyt = []
				if(FlockhartPlugin::FORMAT_CYT_ID.keys.include?(array[1]))
					FlockhartPlugin::FORMAT_CYT_ID[array[1]].each { |name|
						cyt.push(name)
					}
				else
					cyt = array[1]
				end
				objs = {}
        unless cyt.is_a?(Array)
          cyt = [cyt]
        end
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
				if(string.match(/-\/-\/-/u))
					array = string.split(/&\/&\/&/u)
					@duplicates.push(array.shift)
				else
					array = string.split(/&\/&\/&/u)
				end
				parse_array(array)
			end
			def send_flowing_data(data) 
        if(match = /SUBSTRATES|INHIBITORS|INDUCERS/u.match(data))
          @current_table = match.to_s.downcase
				elsif(@current_tablehandler)
					if(@current_table)
						@data = data.strip
						case @category
						when "start"
							@current_category = data.split(/:/u).first.downcase
							@data = 'cat'
						when "end"
							@current_category = nil
							@category = nil
						end
            if /:$/.match(@data)
              @current_category = @data[0...-1].downcase
							@data = 'cat'
            end
						if(@tr_class && @tr_class.match(/lite/u) && @data!='cat')
							data = clear_string(data)
							return unless check_string(data)
							if(data.match(/\(not/u))
								data.slice!(/\(not/u)
								data.slice!(/\)/u)
								data = @previous_data << "-/-/-" + data.strip
							end
							if(@ignore_next && !data.match(/=/u))
								@ignore_next = false
							else
								if(data.match(/=/u))
									data.slice!(/=/u)
									@ignore_next = true
								end
								data_string = write_substance_string(data)
								@previous_data = data
								@current_tablehandler.send_cdata(data_string) if check_string(data_string)
							end
						elsif(@tr_class && @tr_class.match(/green/u) && @data!='cat')
							type = @current_table.dup
							type_cyt = type << "@/@/@" << data.strip
							@current_tablehandler.send_cdata(type_cyt) if check_string(type_cyt)
						end
					end
				end
			end
			def send_image(src)
        case File.basename(src)
        when "red.jpg"
          @auc_factor = "5"
        when "orange.jpg"
          @auc_factor = "2"
        when "orangeGreen.jpg"
          @auc_factor = "1.75"
        when "green.jpg"
          @auc_factor = "1.25"
        when "blue.jpg"
          @auc_factor = "1"
        end
			end
			def send_line_break
				unless(@current_tablehandler.nil?)
					@current_tablehandler.next_line
				end
			end
			def start_tr(attributes)
        case attributes && attributes.first
        when ["bgcolor", "#CCCCCC"]
          @tr_class = 'green'
        when ["valign", "top"]
          @tr_class = 'lite'
        else
          @tr_class = nil
        end
			end
			def write_substance_string(data)
				cat = @current_category
				name = data.strip
        string = name.dup
        string << "*/*/*#{cat}"
        string << "*/*/*#@auc_factor" 
				string << "&/&/&"
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
				if handler && (link = handler.attribute('href'))
					valid_link = link.to_s.split(/#/u)[0]
					if(valid_link && valid_link.match(/.asp$/u) \
             && !(@links.include?(valid_link) \
                  || /www.fda.gov/u.match(valid_link) \
                  || FlockhartPlugin::INVALID_LINKS.include?(valid_link)))
						@links.push(valid_link)
					end
				end
			end
			def start_tr(attrs)
			end
		end
		class FlockhartPlugin < Plugin
			HTTP_SERVER = 'medicine.iupui.edu'
			HTML_PATH = '/clinpharm/DDIs'
			TARGET = File.expand_path('../../data/html/interaction/flockhart', File.dirname(__FILE__))
			TABLE = "table.aspx"
      LINKS = [ "1A2references.asp", "2B6references.asp", "2C8references.asp",
        "2C9references.asp", "2C19references.asp", "2D6references.asp",
        "2E1references.asp", "3A457references.asp" ]
			FORMAT_CYT_ID = {
				"3A457"		=>	["3A4", "3A5-7"],
				"3A4,5,7"	=>	["3A4", "3A5-7"],
				"3A,4,5,7"=>	["3A4", "3A5-7"],
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
      def parse_detail_page cyt_name, page
        div = (page/"div[@class=content_content_inner]").first
        cytochrome = Cytochrome.new cyt_name
        buffer = ''
        connection = nil
        current_table = nil
        abstract_link = nil
        (div/'td').each do |td|
          td.children.each do |child|
            if child.is_a?(Nokogiri::XML::Text)
              buffer << child.to_s.strip
            else
              case child.name
              when 'a'
                abstract_link = Interaction::AbstractLink.new
                match = /^(.*?)\s*(\[)?$/.match buffer
                abstract_link.text = match[1]
                buffer = match[2].to_s
                buffer << child.inner_text
                abstract_link.href = child.attributes["href"].to_s
                abstract_link.info = buffer
                connection.add_link abstract_link
              when 'b'
                if current_table
                  name = "#{current_table.capitalize}Connection"
                  klass = Interaction.const_get name
                  connection = klass.new child.inner_text.capitalize, 'en'
                  cytochrome.add_connection connection
                end
              when 'br'
                if "\n" == buffer[-1,1]
                  buffer = ''
                elsif !buffer.empty?
                  buffer << "\n"
                end
              when 'h2'
                if match = /SUBSTRATE|INHIBITOR|INDUCER/u.match(child.inner_text)
                  current_table = match.to_s.downcase
                end
              end
            end
          end
        end
        cytochrome
      end
      def parse_detail_pages
        agent = Mechanize.new
        links = get_table_links
        cytochromes = {}
        links.each do |link|
          cyt_name = link.split("references").first
          url = sprintf "http://%s%s/%s", HTTP_SERVER, HTML_PATH, link
          page = agent.get url
          cytochrome = parse_detail_page cyt_name, page
          if(names = FORMAT_CYT_ID[cyt_name])
            names.each do |name|
              cytochromes.store(name, cytochrome)
            end
          else
            cytochromes.store(cyt_name, cytochrome)
          end
        end
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
					@parsing_errors.store("flockhart", 'different amount of links found in table.asp')
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
				html.gsub!('<br /><br />', '<category />')
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
