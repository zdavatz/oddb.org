#!/usr/bin/env ruby
# -- oddb -- 16.12.2004 -- jlang@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'util/http'
require 'util/html_parser'

module ODDB
	module DocData
		class DoctorFormatter < HtmlFormatter
			def push_tablecell(attributes)
				unless(@tablehandler.nil?)
					@tablehandler.next_cell(attributes, true)
				end
			end
		end
		class DoctorWriter < NullWriter
			attr_reader :collected_values
			TRANSLATE_KEYS = {
				'Telefon:'	=>	:fon,
				'Telefax:'	=>	:fax,	
				'Email:'		=>	:email,
				'Adresse:'	=>	:addresses,
				'PLZ:'			=>	:plz,
				'Ort:'			=>	:city,
				'Anrede:'		=>	:salutation,
				'Titel:'		=>	:title,
				'Name:'			=>	:name,
				'Vorname:'	=>	:firstname,
				'Email:'		=>	:email,
				'EAN:'			=>	:ean13,
				'Praxis'		=>	:praxis,
				'Staatsexamensjahr:'		=>	:exam,
				'Korrespondenzsprache:'	=>	:language,
				'Facharzttitel:'				=>	:specialities,
				'Fähigkeitsausweis:'		=>	:abilities,
				'Fertigkeitsausweis:'		=>	:skills,
			}
			def initialize
				@tablehandlers = []
				@collected_values = {}
				@type = nil
			end
			def translate_key(string)
				TRANSLATE_KEYS[string.strip]
			end
			def extract_data
				type = nil
				if(handler = @tablehandlers.at(2))
					handler.each_row { |row|
						if(row.cdata(0))
							unless(row.cdata(0).is_a?(Array))
								if(row.cdata(0).match(/Praxis-Adresse/))
									type = :praxis
								elsif(row.cdata(0).match(/Adresse Arbeitsort/))
									type = :work
								end	
							end
						end
						handle_data(row.cdata(0), row.cdata(1), type)
						handle_data(row.cdata(2), row.cdata(3), type)
						@current_address = nil
					}
				end
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
			def handle_data(key, value, type)
				if(key.is_a?(Array))
					handle_array_data(key, value, type)
				else
					handle_scalar_data(key, value)
				end
			end
			def handle_array_data(ary, value, type)
				if(ary.first == "Adresse:")
					plz_city = get_plz_city(value)
					addr_hash = {
						:plz	=>	plz_city.first,
						:city	=>	plz_city.last,
						:lines	=>	value,
						:type		=>	type,
					}
					handle_scalar_data('Adresse:', addr_hash)
					@current_address = addr_hash
				else
					ary.each_with_index { |str, idx|
						val = (value.is_a? Array) ? 
							value.at(idx) : value
						handle_scalar_data(str, val)
					}
				end
			end
			def handle_scalar_data(key, value)
				string = key.to_s.delete("\240").strip
				if(key = translate_key(string))
					if(@current_address)
						@current_address.store(key, value)
					elsif(@collected_values.include?(key))
						values = @collected_values[key]
						unless values.is_a?(Array)	
							@collected_values[key] = [values]
						end
						@collected_values[key].push(value)
					else
						@collected_values.store(key, value)
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
	end
end
