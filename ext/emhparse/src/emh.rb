#!/usr/bin/env ruby
# EMHPlugin -- oddb -- 20.10.2003 -- maege@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'plugin/plugin'
require 'util/html_parser'
require 'util/http'
require 'plugin/medwin'
require 'iconv'
require 'cgi'
require 'csv'

module ODDB
	class EMHFormatter < HtmlFormatter
		def push_tablecell(attributes)
			unless(@tablehandler.nil?)
				@tablehandler.next_cell(attributes, true)
			end
		end
	end
	class EMHMedwinWriter < NullWriter
		def initialize
			@tablehandlers = []
			@linkhandlers = []
		end
		def extract_data
			data = {}
			@tablehandlers.each { |handler|
				unless(handler.nil?)
					id = handler.attributes[3].last
					if(id.match(/DgMedwinPartner/))
						handler.each_row { |row|
							unless(row.children(0).empty?)
								arr = row.children(0).first.attributes['href'].split("$")
								data.store(arr[1], [row.cdata(1), row.cdata(2), row.cdata(3)])
							end
						}
					end
				end
			}
			data
		end
		def new_linkhandler(handler)
			unless(@current_tablehandler.nil?)
				@current_tablehandler.add_child(handler)
			end
		end
		def new_tablehandler(handler)
			@current_tablehandler = handler
			@tablehandlers.push(handler)
		end
		def send_flowing_data(data) 
			unless(@current_tablehandler.nil?)
				@current_tablehandler.send_cdata(data)
			end
		end
	end
	class EMHWriter < NullWriter
		attr_reader :collected_values
		WORK_KEYS = {
			:work_fon	=>	'Telefon:',
			:work_fax	=>	'Telefax:',
			:work_email	=>	'Email:',
			:work_address	=>	'Adresse:',
			:work_plz	=>	'PLZ:',
			:work_city=>	'Ort:',
		}
		PRAX_KEYS = {
			:prax_fon	=>	'Telefon:',
			:prax_fax	=>	'Telefax:',
			:prax_email	=>	'Email:',
			:prax_address	=>	'Adresse:',
			:prax_plz	=>	'PLZ:',
			:prax_city=>	'Ort:',
		}
		def initialize
			@tablehandlers = []
			@collected_values = {}
			@type = nil
		end
		def check_string(string, type)
			key = nil 
			if(type == 'work')
				WORK_KEYS.each { |csv_key, val|
					key = csv_key if (string == val)
				}
				key = get_key(string) if (key.nil?)
			elsif(type == 'prax')
				PRAX_KEYS.each { |csv_key, val|
					key = csv_key if (string == val)
				}
				key = get_key(string) if (key.nil?)
			elsif (type.nil?)
				key = get_key(string)
			end
			key
		end
		def extract_data
			if(handler = @tablehandlers.at(2))
				handler.each_row { |row|
					if(row.cdata(0))
						unless(row.cdata(0).is_a?(Array))
							if(row.cdata(0).match(/Praxis-Adresse/))
								@type = 'prax'
							elsif(row.cdata(0).match(/Adresse Arbeitsort/))
								@type = 'work'
							end	
						end
					end
					handle_data(row.cdata(0), row.cdata(1), @type)
					handle_data(row.cdata(2), row.cdata(3), @type)
				}
			end
		end
		def get_key(string)
			key = nil 
			EMHPlugin::CSV_COMPLETE.each { |csv_key, val|
				if(val == "Praxis" || val == "Mitglied")
					key = csv_key if (string == val)
				else
					key = csv_key if (string == (val+":"))
				end
			}
			key
		end
		def get_plz_city(array)
			arr = []
			array.each { |str|
				if(str.match(/[\d]{4}/))
					arr = str.split(" ")
				end
			}
			arr
		end
		def handle_data(string, value, type)
			if(string.is_a?(Array))
				if(string == ["Adresse:", ""])
					plz_city = get_plz_city(value)
					plz = plz_city.first 
					city = plz_city.last
					unless(plz.nil? || city.nil?)
						handle_data('PLZ:', plz, type)
						handle_data('Ort:', city, type)
					end
					handle_data(string.first, value, type)
				else
					string.each_with_index { |str, idx|
						val = (value.is_a? Array) ? value.at(idx) : value
						handle_data(str, val, type)
					}
				end
			else
				string = string.to_s.delete("\240").strip
				unless(string == "")
					key = check_string(string, type)
				end
				if(value.is_a?(Array))
					output = value
				else
					output = String.new
					value.to_s.each {|s| output << s }
				end
				if(@collected_values.include?(key))
					values = @collected_values[key].to_a
					output = output.to_a unless output.is_a?(Array)
					new_values = values.concat(output)
					@collected_values[key] = new_values
				else
					@collected_values.store(key, output) unless key.nil?
				end
			end
		end
		def new_tablehandler(handler)
			@current_tablehandler = handler
			@tablehandlers.push(handler)
		end
		def send_flowing_data(data) 
			unless(@current_tablehandler.nil?)
				@current_tablehandler.send_cdata(data)
			end
		end
		def send_line_break
			unless(@current_tablehandler.nil?)
				@current_tablehandler.next_line
			end
		end
	end
	class EMHPlugin < Plugin
		attr_reader :keys
		HTTP_SERVER = 'www.emh.ch'
		MEDWIN_SERVER = 'www.medwin.ch'
		HTML_PATH = '/medical_adresses/physicians_fmh/detail.cfm'
		CSV_PATH = File.expand_path('../data/csv/emh_addresses.csv', File.dirname(__FILE__))
		RANGE = 16099...16101
		#RANGE = 11457...70000
		RETRIES = 3
		RETRY_WAIT = 5
		CSV_COMPLETE = {
			:gender			=>	'Anrede',
			:title			=>	'Titel',
			:name				=>	'Name',
			:surname		=>	'Vorname',
			:email			=>	'Email',
			:ean13			=>	'EAN',
			:email			=>	'Email',
			:praxis			=>	'Praxis',
			:prax_address	=>	'Praxis-Adresse',
			:prax_fon			=>	'Praxis-Telefon',
			:prax_fax			=>	'Praxis-Telefax',
			:prax_email		=>	'Praxis-Email',
			:prax_plz			=>	'Praxis-PLZ',
			:prax_city		=>	'Praxis-Ort',
			:work_address	=>	'Arbeitsort-Adresse',
			:work_fon			=>	'Arbeitsort-Telefon',
			:work_fax			=>	'Arbeitsort-Telefax',
			:work_email		=>	'Arbeitsort-Email',
			:work_plz			=>	'Arbeitsort-PLZ',
			:work_city		=>	'Arbeitsort-Ort',
			:exam				=>	'Staatsexamensjahr',
			:language		=>	'Korrespondenzsprache',
			:specialist	=>	'Facharzttitel',
			:ability		=>	'Fähigkeitsausweis',
			:skill			=>	'Fertigkeitsausweis',
			#:member			=>	'Mitglied',
		}
		CSV_ORDER = [
			:gender,
			:title,
			:name,
			:surname,
			:email,
			:ean13,
			:email,
			:praxis,
			:prax_address,
			:prax_fon,
			:prax_fax,
			:prax_email,
			:prax_plz,
			:prax_city,
			:work_address,
			:work_fon,
			:work_fax,
			:work_email,
			:work_plz,
			:work_city,
			:exam,
			:language,
			:specialist,
			:ability,
			:skill,
			:member,
		]
		def initialize(app)
			@keys = []
			@addresses_found = 0 
			@session = EMHSession.new(MEDWIN_SERVER)
			@medwin_template = {
				:ean13		=>	[1,0],
			}
			super
		end
		def data_path(emh_id)
			attributes = {
				'ds1nr'	=>	emh_id,	
			}
			emh_path(attributes)
		end
		def emh_path(hsh)
			attributes = hsh.sort.collect { |pair| 
				pair.join('=')
			}.join('&')
			[ HTML_PATH, attributes ].join('?')
		end
		def emh_data(emh_id)
			html = emh_data_body(emh_id)
			if(html.index('Name:'))
				parse_emh_data(html)
			else
				nil
			end
		end
		def emh_data_body(emh_id)
			retr = RETRIES
			begin
				session = Net::HTTP.new(HTTP_SERVER)
				resp = session.get(data_path(emh_id))
				if(resp.is_a? Net::HTTPOK)
					enc_resp = ODDB::HttpSession::ResponseWrapper.new(resp)
					enc_resp.body
				end
			rescue Timeout::Error
				if(retr > 0)
					sleep RETRY_WAIT
					retr -= 1
					retry
				end
			end
		end
		def emh_data_add_ean(emh_id)
			data = emh_data(emh_id)
			unless(data.nil?)
				result = parse_medwin_data(@session.medic_html(data))
				keys = []
				result.each { |key, value|
					if(value[1]==data[:surname])
						keys.push(key)
					end
				}
				ean13 = nil
				if(keys.size == 1)
					ean13 = parse_medwin_detail_data(@session.detail_html(keys.first))[:ean13]
				end
				unless(ean13.nil?)
					data.store(:ean13, ean13)
				end
				data
			end
		end
		def parse_emh_data(html)
			writer = EMHWriter.new
			formatter = EMHFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
			writer.extract_data
			writer.collected_values
		end
		def parse_medwin_data(html)
			writer = EMHMedwinWriter.new
			formatter = EMHFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
			writer.extract_data
		end
		def parse_medwin_detail_data(html)
			writer = MedwinWriter.new(@medwin_template)
			formatter = EMHFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
			writer.extract_data
		end
		def update(ean13_option=nil)
			CSV.open(CSV_PATH, 'wb') do |writer|
				array = []
				CSV_ORDER.each { |key|
					array.push(CSV_COMPLETE[key])	
				}
				writer << array
				RANGE.each { |id|
					puts id
					if(ean13_option.nil?)
						parsed_values = emh_data(id)
					else
						parsed_values = emh_data_add_ean(id)
					end
					unless(parsed_values.nil? || parsed_values.empty?)
						writer << prepare_csv_data(parsed_values)
						@addresses_found += 1 
					end
				}	
			end
		end
		def report
			lines = [
				"Found #{@addresses_found} Addresses",
			]
			lines.join("\n")
		end
		def prepare_csv_data(data)
			array = []
			CSV_ORDER.each { |key|
				if(value = data[key])
					if(value.is_a?(Array))
						value.delete("")
						array.push(value.join("; "))
					else
						array.push(data[key])
					end
				else
					array.push(nil)
				end
			}
			array
		end
	end
	class EMHSession < HttpSession
		HTTP_PATH = '/frmSearchPartner.aspx?lang=de' 
		def initialize(server)
			@value_viewstate = nil
			super
		end
		def build_first_post_hash(name)
			{
				'__EVENTTARGET'		=>	'',
				'txtSearchName'		=>	name,
				'btnSearch'				=>	'Suche',
			}
		end
		def build_second_post_hash(value_viewstate, ctl)
			{
				'__EVENTTARGET'		=>	"DgMedwinPartner:#{ctl}:_ctl0",
				'__VIEWSTATE'			=>	value_viewstate,
			}
		end
		def handle_resp(html)
			value_viewstate = String.new
			html.each { |line|
				if(line.match(/VIEWSTATE/))
					arr = line.split('value')[1].split('"')
					value_viewstate = arr[1]
				end
			}
			value_viewstate
		end
		def medic_html(data)
			name = Iconv.iconv('utf8', 'latin1', data[:name]).first
			name = name.gsub(/'/, "").split(" ")
			hash = build_first_post_hash(name.first)
			resp = post(HTTP_PATH, hash)
			@value_viewstate = handle_resp(resp.body)
			resp.body
		end
		def detail_html(ctl)
			hash = build_second_post_hash(@value_viewstate, ctl)
			resp = post(HTTP_PATH, hash)
			@value_viewstate = nil
			resp.body
		end
	end
end
