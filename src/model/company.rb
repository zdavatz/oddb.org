#!/usr/bin/env ruby
# Company -- oddb -- 28.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'model/registration_observer'

module ODDB
	class Company
		include Persistence
		include RegistrationObserver
		attr_accessor :business_area, :generic_type, :complementary_type
		attr_accessor :cl_status, :fi_status, :pi_status
		attr_accessor :name, :ean13, :powerlink, :logo_filename
		alias :power_link= :powerlink=
		alias :power_link :powerlink
		alias :to_s :name
		attr_accessor	:contact, :contact_email, :regulatory_email
		attr_accessor	:url, :phone, :fax, :address_email
		alias :email :address_email
		attr_accessor :address, :plz, :location
		attr_reader :user
		def initialize
			@cl_status = false
			super
		end	
		def init(app)
			@pointer.append(@oid)
		end
		def has_user?
			!@user.nil?
		end
		def inactive_registrations
			@registrations.reject { |registration|
				registration.active?
			}
		end
		def search_terms
			[
				@name,
				@address,
			]
		end
		def atc_classes
			@registrations.collect { |registration|
				registration.atc_classes				
			}.flatten.compact.uniq
		end
		def listed?
			@cl_status
		end
		def merge(other)
			regs = other.registrations.dup
			regs.each { |reg|
				reg.company = self
			}
			@registrations.odba_isolated_store
		end
		def user=(user)
			@user = user
			self.odba_isolated_store
			@user
		end
		def pointer_descr
			@name
		end
		private
		def adjust_types(input, app=nil)
			input.each { |key, val|
				case key
				when :fi_status, :cl_status, :pi_status
					input[key] = [
						/true/i, /y/i, /ja?/i, /1/
						].any? { |pattern|
						pattern.match(val.to_s)
					}
				when :powerlink
					if(val.empty?)
						input[key] = nil
					end
				when :generic_type, :complementary_type
					if(val.is_a? String)
						input[key] = val.intern
					end
				end
			}
			input
		end
	end
end
