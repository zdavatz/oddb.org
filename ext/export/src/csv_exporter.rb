#!/usr/bin/env ruby
# OdbaExporter::CsvExporter -- oddb -- 26.08.2005 -- hwyss@ywesee.com

require 'csvparser'

module ODDB
	module OdbaExporter
		module CsvExporter
			DOCTOR = [ :ean13, :exam, :salutation, :title, :firstname,
				:name, :praxis, :first_address_data, :email, :language, ]
			ADDRESS = [:type, :address, :location, :canton, :fons, :faxs]
			def CsvExporter.address_data(item)
				collect_data(ADDRESS, item)
			end
			def CsvExporter.collect_data(keys, item)
				keys.collect { |key|
					if(item.nil?)
						''
					elsif(item.respond_to?(key))
						item.send(key).to_s
					else
						self.send(key, item)
					end
				}
			end
			def CsvExporter.dump(keys, item, fh)
				data = collect_data(keys, item).flatten
				fh << CSVLine.new(data).to_s(false, ';') << "\n"
			end
			def CsvExporter.faxs(item)
				item.fax.join(',')
			end
			def CsvExporter.fons(item)
				item.fon.join(',')
			end
			def CsvExporter.first_address_data(item)
				addr = item.praxis_address || item.address(0)
				address_data(addr)
			end
		end
	end
end
