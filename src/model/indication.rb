#!/usr/bin/env ruby
# Indication -- oddb -- 12.05.2003 -- hwyss@ywesee.com 

require 'util/language'
require 'model/registration_observer'

module ODDB
	class Indication
		include Language
		include RegistrationObserver
		def atc_classes
			@registrations.collect { |reg| 
				reg.atc_classes
			}.flatten.compact.uniq
		end
	end
end
