#!/usr/bin/env ruby
# RegistrationObserver -- oddb -- 29.10.2003 -- rwaltert@ywesee.com

module ODDB
	module RegistrationObserver
		attr_reader :registrations
		def initialize
			@registrations = []
			super
		end
		def add_registration(registration)
			@registrations.push(registration).last
		end
		def empty?
			@registrations.empty?
		end
		def registration_count
			@registrations.size
		end
		def remove_registration(registration)
			@registrations.delete(registration) 
		end
		def iksnrs
			@registrations.collect { |reg| reg.iksnr }
		end
	end
end
