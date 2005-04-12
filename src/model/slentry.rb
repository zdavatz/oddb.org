#!/usr/bin/env ruby
# SlEntry -- oddb -- 03.03.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'model/limitationtext'
require 'date'

module ODDB
	class SlEntry
		include Persistence
		attr_accessor :limitation, :limitation_points
		attr_accessor :introduction_date, :bsv_dossier
		attr_reader :limitation_text
		def create_limitation_text
			@limitation_text = LimitationText.new
		end
		def delete_limitation_text
			@limitation_text = nil
			self.odba_store
			nil
		end
		def pointer_descr
			:sl_entry
		end
		private
		def adjust_types(values, app=nil)
			values = values.dup
			values.each { |key, value|
				case(key)
				when :introduction_date
					values[key] = if (value.is_a? Date)
						value
					else
						Date.parse(value.tr('.', '-'))
					end
				when :limitation
					values[key] = ([true, 'true', 'Y'].include? value) ? true : false
				when :limitation_points
					points = value.to_i
					values[key] = (points > 0) ? points : nil
				end unless value.nil?
			}
		end
	end
end
