#!/usr/bin/env ruby
# Sponsor -- oddb -- 29.07.2003 -- maege@ywesee.com

require 'date'
require 'util/persistence'

module ODDB
	class Sponsor
		PATH = File.expand_path(
			'../../doc/resources/sponsor', 
			File.dirname(__FILE__))
		include Persistence
		attr_accessor :sponsor_until, :company
		attr_reader :logo_filename, :logo
		def initialize
			@pointer = Pointer.new([:sponsor])
		end
		def company_name
			@company.name if @company
		end
		alias :name :company_name
		def logo=(upload)
			return if(upload.name.nil? || upload.name.empty?)
			if(@logo_filename)
				old = File.expand_path(@logo_filename, PATH)
				if(File.exist?(old))
					File.delete(old)
				end
			end
			@logo_filename = upload.name
			path = File.expand_path(upload.name, PATH)
			File.open(path, 'wb') { |fh|
				fh << upload.content
			}
		end
		def represents?(pac)
			pac.respond_to?(:company) && (pac.company == @company)
		end
		private
		def adjust_types(values, app=nil)
			values.each { |key, val|
				if(val.is_a?(Pointer))
					values[key] = val.resolve(app)
				else
					case key
					when :company
						values[key] = if(val.is_a? String)
							app.company_by_name(val)
						elsif(val.is_a?(Integer))
							app.company(val)
						else
							nil
						end
					when :sponsor_until
						values[key] = (val.is_a? Date) ? val : nil
					end
				end
			}
		end
	end
end
