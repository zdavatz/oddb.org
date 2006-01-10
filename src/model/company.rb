#!/usr/bin/env ruby
# Company -- oddb -- 28.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'model/registration_observer'
require 'model/address'
require 'model/user'

module ODDB
	class Company
		include Persistence
		include RegistrationObserver
		include UserObserver
		include AddressObserver
		ODBA_SERIALIZABLE = ['@addresses']
		attr_accessor :address_email, :business_area, :business_unit,
			:cl_status, :complementary_type, :contact, :ean13, 
			:generic_type, :invoice_email, :logo_filename, :name,
			:disable_autoinvoice, :powerlink, :regulatory_email, :url, 
			:patinfo_price, :lookandfeel_price, :lookandfeel_member_count, 
			:lookandfeel_member_price, :index_price, :index_package_price,
			:hosting_price, :hosting_invoice_date
		attr_writer :pref_invoice_date, :lookandfeel_invoice_date, 
			:index_invoice_date
		alias :fullname :name
		alias :power_link= :powerlink=
		alias :power_link :powerlink
		alias :to_s :name
		alias :email :address_email
		def initialize
			@addresses = [Address2.new]
			@cl_status = false
			super
		end	
		def init(app)
			@pointer.append(@oid)
		end
		def active_package_count
			@registrations.inject(0) { |sum, reg|
				sum + reg.active_package_count
			}
		end
		def atc_classes
			@registrations.collect { |registration|
				registration.atc_classes				
			}.flatten.compact.uniq
		end
		def inactive_registrations
			@registrations.reject { |registration|
				registration.public_package_count > 0
			}
		end
		def index_invoice_date
			@index_invoice_date = _yearly_repetition(@index_invoice_date)
		end
		def listed?
			@cl_status
		end
		def lookandfeel_invoice_date
			@lookandfeel_invoice_date = _yearly_repetition(@lookandfeel_invoice_date)
		end
		def merge(other)
			regs = other.registrations.dup
			regs.each { |reg|
				reg.company = self
				reg.odba_isolated_store
			}
			@registrations.odba_isolated_store
		end
		def pointer_descr
			@name
		end
		def pref_invoice_date
			@pref_invoice_date = _yearly_repetition(@pref_invoice_date)
		end
		def refactor_addresses
			addr = Address2.new
			addr.location = [@plz, @location].join(" ")
			addr.address = @address
			addr.pointer = @pointer + [:address, 0]
			addr.fon = [ @phone ].compact
			addr.fax = [ @fax ].compact
			@phone = @fax = @plz = @location = @address = nil
			@addresses = [ addr ]
		end
		def search_terms
			terms = @name.split(/[\s\-()]+/).select { |str| str.size >= 3 }
			terms += [
				@name, @ean13, 
			]
			@addresses.each { |addr| 
				terms += addr.search_terms
			}
			terms.compact
		end
		private
		def adjust_types(input, app=nil)
			input.each { |key, val|
				case key
				when :powerlink
					if(val.to_s.empty?)
						input[key] = nil
					end
				when :generic_type, :complementary_type
					if(val.is_a? String)
						input[key] = val.intern
					end
				when :lookandfeel_price, :lookandfeel_member_price, 
					:index_price, :index_package_price, :hosting_price
					input[key] = (val.to_f * 100) unless(val.nil?)
				end
			}
			input
		end
		def _yearly_repetition(date)
			if(date)
				today = Date.today
				while(date < today)
					date = date >> 12
				end
				date
			end
		end
	end
end
