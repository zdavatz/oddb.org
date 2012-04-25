#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::RegistrationObserver -- oddb.org -- 25.04.2012 -- yasaka@ywesee.com
# ODDB::RegistrationObserver -- oddb.org -- 24.10.2011 -- mhatakeyama@ywesee.com
# ODDB::RegistrationObserver -- oddb.org -- 29.10.2003 -- rwaltert@ywesee.com

module ODDB
	module RegistrationObserver
		attr_reader :registrations
		def initialize
			@registrations = []
			super
		end
		def add_registration(registration)
			unless(@registrations.include?(registration))
				@registrations.push(registration)
				@registrations.odba_isolated_store
        odba_isolated_store # update indices
			end
			registration
		end
		def empty?
			@registrations.empty?
		end
		def registration_count
			@registrations.size
		end
		def remove_registration(registration)
			if(@registrations.delete(registration))
				@registrations.odba_isolated_store
        odba_isolated_store # update indices
			end
			registration
		end
		def iksnrs
			@registrations.collect { |reg| reg.iksnr }
		end
	end
end
