#!/usr/bin/env ruby
# Address -- oddb -- 20.09.2004 -- jlang@ywesee.com

require 'util/persistence'

module ODDB
	class Address 
		attr_accessor :lines, :fon, :fax,
			:plz, :city, :type
		
		def city
			if(match =/[^0-9]+/.match(self.lines[-1]))
				 match.to_s.strip
			end
		end
		def lines
			@lines.delete_if { |line| line.strip.empty? }
		end
		def lines_without_title
			self.lines.select { |line|
				!/(Prof(\.|ess))|(dr\.\s*med)|(Docteur)/i.match(line)
			}
		end
		def number 
			if(match = /[0-9][^,]*/.match(self.lines[-2]))
				match.to_s.strip
			end
		end
		def plz
			if(match = /[1-9][0-9]{3}/.match(self.lines[-1]))
				 match.to_s
			end
		end
		def search_terms
			ODDB.search_terms([self.lines_without_title, @fon, @fax, @plz, @city])
		end
		def street
			if(match = /[^0-9,]+/.match(self.lines[-2]))
				match.to_s.strip
			end
		end
		def <=>(other)
			self.lines <=> other.lines
		end
	end
	class Address2
		include PersistenceMethods
		@@city_pattern = /[^0-9]+[^0-9\-](?!-)([0-9]+)?/
		attr_accessor :name, :additional_lines, :address,
			:location, :title, :fon, :fax, :canton, :type
		alias :address_type :type
		alias :pointer_descr :name
		alias :contact :name
		def initialize 
			super
			@additional_lines = []
			@fon = []
			@fax = []
		end
		def city
			if(match = @@city_pattern.match(@location.to_s))
				 match.to_s.strip
			end
		end
		def replace_with(other)
			@name = other.name
			@title = other.title
			@additional_lines = other.additional_lines
			@address = other.address
			@location = other.location
			@fon = other.fon
			@fax = other.fax
			@canton = other.canton
			@type = other.type
		end
		def lines
			lines = lines_without_title
			if(!@title.to_s.empty?)
				lines.unshift(@title)
			end
			lines
		end
		def lines_without_title
			([
				@name,
			] + @additional_lines +
			[
				@address,
				location_canton,
		  ]).delete_if { |line| line.to_s.empty? }
		end
		def location_canton
			if(@canton && @location)
				@location + " (#{@canton})"
			else
				@location
			end
		end
		def number 
			if(match = /[0-9][^\s,]*/.match(@address.to_s))
				match.to_s.strip
			end
		end
		def plz
			if(match = /[1-9][0-9]{3}/.match(@location.to_s))
				 match.to_s
			end
		end
		def search_terms
			ODDB.search_terms([self.lines_without_title, @fon, @fax, 
				self.city, self.plz])
		end
		def street
			if(match = /[^0-9,]+/.match(@address.to_s))
				match.to_s.strip
			end
		end
		def ydim_lines
			[@address].concat(@additional_lines)
		end
		def <=>(other)
			self.lines <=> other.lines
		end
	end
	module AddressObserver
		attr_accessor :addresses
		attr_reader :fullname
		def address(pos)
			@addresses[pos.to_i]
		end
		def create_address(pos=nil)
			addr = Address2.new
			@addresses.push(addr)
			addr
		end
		def ydim_address_lines(pos=0)
			@addresses.at(pos).ydim_lines
		end
		def ydim_location(pos=0)
			@addresses.at(pos).location
		end
	end
	class AddressSuggestion < Address2
		include Persistence
		ODBA_SERIALIZABLE = ['@additional_lines', '@fax',
			'@fon'] 
		attr_accessor :address_pointer, :message, 
			:email_suggestion, :email, :time, :fullname
		alias :pointer_descr :fullname
		def init(app = nil)
			super
			@pointer.append(@oid)
		end
	end
end
