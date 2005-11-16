#!/usr/bin/env ruby
# Narcotic -- oddb -- 04.11.2005 -- ffricker@ywesee.com

require 'util/persistence'
require 'util/language'

module ODDB
	class Narcotic
		include Persistence
		attr_reader	:packages, :reservation_text
		attr_accessor :casrn, :swissmedic_code, :substance, :category
		def create_reservation_text
			@reservation_text = Text::Document.new
		end
		def initialize
			@packages = []
			super
		end
		def init(app=nil)
			@pointer.append(@oid)
		end
		def add_package(package)
			@packages.push(package)
			@packages.odba_isolated_store
			@packages.last
		end
		def checkout
			@substance.narcotic = nil
			@substance.odba_store
			@packages.each { |pack| 
				pack.narcotic = nil
				pack.odba_store 
			}
		end
		def remove_package(package)
			if(@packages.delete(package))
				@packages.odba_isolated_store
				package
			end
		end
	end
end
