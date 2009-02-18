#!/usr/bin/env ruby
# Narcotic -- oddb -- 04.11.2005 -- ffricker@ywesee.com

require 'util/persistence'
require 'util/language'
require 'model/package_observer'

module ODDB
	class Narcotic
		include Persistence
    include PackageObserver
		attr_reader	:reservation_text, :substances
		attr_accessor :category
		def initialize
			@substances = []
			super
		end
		def init(app=nil)
			@pointer.append(@oid)
		end
		def add_substance(substance)
			unless(@substances.include?(substance))
				@substances.push(substance)
				@substances.odba_store
			end
			substance
		end
		def casrn
			@substances.collect { |sub| sub.casrn }.first
		end
		def checkout
			@substances.each { |sub| 
				sub.narcotic = nil 
				sub.odba_store
			}
			@packages.each { |pack| 
				pack.remove_narcotic(self)
				pack.odba_store 
			}
      @substances.odba_delete
		end
		def create_reservation_text
			@reservation_text = Text::Document.new
		end
		def pointer_descr
			to_s
		end
		def remove_substance(substance)
			if(sub = @substances.delete(substance))
				@substances.odba_store
				sub
			end
		end
		def swissmedic_code 
			@substances.collect { |sub| sub.swissmedic_code }
			#@substance.swissmedic_code unless(@substance.nil?)
		end
		def to_s
			@substances.sort_by { |sub| sub.to_s }.first.to_s
		end
	end
end
