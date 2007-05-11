#!/usr/bin/env ruby
# OdbaExporter::CsvExporter -- oddb -- 26.08.2005 -- hwyss@ywesee.com

require 'csv'

module ODDB
	module OdbaExporter
		module CsvExporter
			ANALYSIS = [ :groupcd, :poscd, :analysis_anonymous, :defr,
				:analysis_footnote, :analysis_taxnote, 
				:analysis_limitation, :analysis_list_title, 
				:lab_areas, :taxpoints, :finding,
				:analysis_permissions ]
			DOCTOR = [ :ean13, :exam, :salutation, :title, :firstname,
				:name, :praxis, :first_address_data, :email, :language, 
				:specialities]
			ADDRESS = [:type, :name, :additional_lines, :address,
				:plz, :city, :canton, :fon, :fax]
			DEFR = [:de, :fr] 
			DEFRIT = [:de, :fr, :it] 
			MIGEL = [:migel_code, :migel_subgroup, :product_code,
				:migel_product_text, :accessory_code, :defrit,
        :migel_limitation, :format_price, :qty, :migel_unit,
        :limitation, :format_date]
			MIGEL_SUBGROUP = [:migel_group, :code, :defrit,
				:migel_limitation]
			MIGEL_GROUP = [:code, :defrit, :migel_limitation]
			NARCOTIC = [:casrn, :swissmedic_code, :narc_substance, 
				:category, :narc_reservation_text]
			def CsvExporter.address_data(item)
				collect_data(ADDRESS, item)
			end
			def CsvExporter.analysis_anonymous(item)
				if(item.anonymousgroup)
				[item.anonymousgroup, item.anonymouspos].join('.')
				else
					''
				end
			end
			def CsvExporter.analysis_limitation(item)
				self.defr(item.limitation_text)
			end
			def CsvExporter.analysis_list_title(item)
				self.defr(item.list_title)
			end
			def CsvExporter.analysis_permissions(item)
				[:de, :fr].collect { |lang|
					item.permissions.send(lang).collect { |perm|
						'{' << perm.specialization.to_s << '}:{' \
							<< perm.restriction.to_s << '}'
					}.join(',')
				}
			end
			def CsvExporter.analysis_footnote(item)
				self.defr(item.footnote)
			end
			def CsvExporter.analysis_taxnote(item)
				self.defr(item.taxnote)
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
      def CsvExporter.collect_languages(keys, item)
        descr = if(item.respond_to?(:descriptions))
                  item.descriptions
                else
                  {}
                end
        keys.collect { |key|
          descr.fetch(key.to_s, '')
        }
      end
			def CsvExporter.defr(item)
				self.collect_languages(DEFR, item)
			end
			def CsvExporter.defrit(item)
				self.collect_languages(DEFRIT, item)
			end
			def CsvExporter.dump(keys, item, fh)
        CSV::Writer.generate(fh, ';') { |csv|
          csv << collect_data(keys, item).flatten
        }
			end
			def CsvExporter.first_address_data(item)
				addr = item.praxis_address || item.address(0)
				address_data(addr)
			end
			def CsvExporter.format_date(item)
				if(date = item.date)
					date.strftime('%d.%m.%Y')
				else
					""
				end
			end
			def CsvExporter.format_price(item)
				item.price = item.price / 100.0
				item.price = sprintf("%.2f", item.price)
			end
			def CsvExporter.migel_limitation(item)
				self.defrit(item.limitation_text)
			end
			def CsvExporter.migel_group(item)
				self.collect_data(MIGEL_GROUP, item.group)
			end
			def CsvExporter.migel_product_text(item)
				self.defrit(item.product_text)
			end
			def CsvExporter.migel_subgroup(item)
				self.collect_data(MIGEL_SUBGROUP, item.subgroup)
			end
			def CsvExporter.migel_unit(item)
				self.defrit(item.unit)
			end
			def CsvExporter.narc_reservation_text(item)
				self.defr(item.reservation_text)
			end
			def CsvExporter.narc_substance(item)
				self.defr(item.substance)
			end
		end
	end
end
