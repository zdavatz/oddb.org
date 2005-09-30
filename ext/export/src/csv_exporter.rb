#!/usr/bin/env ruby
# OdbaExporter::CsvExporter -- oddb -- 26.08.2005 -- hwyss@ywesee.com

require 'csvparser'

module ODDB
	module OdbaExporter
		module CsvExporter
			DOCTOR = [ :ean13, :exam, :salutation, :title, :firstname,
				:name, :praxis, :first_address_data, :email, :language, 
				:specialities]
			ADDRESS = [:type, :address, :location, :canton, :fon, :fax]
			DEFRIT = [:de, :fr, :it] 
			MIGEL = [:migel_code, :migel_subgroup, :migel_defrit, 
				:migel_limitation, :format_price, :date, :migel_unit]
			MIGEL_SUBGROUP = [:migel_group, :code, :migel_defrit, 
				:migel_limitation ]
			MIGEL_GROUP = [:code, :migel_defrit]
			def CsvExporter.address_data(item)
				collect_data(ADDRESS, item)
			end
			def CsvExporter.collect_data(keys, item)
				keys.collect { |key|
					if(item.nil?)
						''
					elsif(item.respond_to?(key))
						val = item.send(key)
						if(val.is_a?(Array))
							val = val.join(',')
						end
						val.to_s.gsub("\n", "\v")
					else
						self.send(key, item)
					end
				}
			end
			def CsvExporter.dump(keys, item, fh)
				data = collect_data(keys, item).flatten
				fh << CSVLine.new(data).to_s(false, ';') << "\n"
			end
			def CsvExporter.first_address_data(item)
				addr = item.praxis_address || item.address(0)
				address_data(addr)
			end
			def CsvExporter.format_price(item)
				sprintf("%.2f", item.price)
			end
			def CsvExporter.migel_defrit(item)
				self.collect_data(DEFRIT, item)
			end
			def CsvExporter.migel_limitation(item)
				self.migel_defrit(item.limitation_text)
			end
			def CsvExporter.migel_group(item)
				self.collect_data(MIGEL_GROUP, item.group)
			end
			def CsvExporter.migel_subgroup(item)
				self.collect_data(MIGEL_SUBGROUP, item.subgroup)
			end
			def CsvExporter.migel_unit(item)
				self.migel_defrit(item.unit)
			end
		end
	end
end
