#!/usr/bin/env ruby
# OdbaExporter::CsvExporter -- oddb -- 26.08.2005 -- hwyss@ywesee.com

require 'csvparser'

module ODDB
	module OdbaExporter
		module CsvExporter
			DOCTOR = [ :ean13, :salutation, :title, :firstname,
				:name, :praxis, :praxis_address_data, :email, :language, ]
			ADDRESS = [:address, :location, :canton, :fons, :faxs]
			def CsvExporter.address_data(item)
				collect_data(ADDRESS, item)
			end
			def CsvExporter.collect_data(keys, item)
				keys.collect { |key|
					if(item.respond_to?(key))
						item.send(key).to_s
					elsif(item)
						self.send(key, item)
					else
						''
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
			def CsvExporter.praxis_address_data(item)
				address_data(item.praxis_address)
			end
		end
	end
end
