#!/usr/bin/env ruby
# Narcotic -- oddb -- 04.11.2005 -- ffricker@ywesee.com

require 'util/persistence'
require 'util/language'

module ODDB
	class Narcotic
		include Persistence
		attr_reader	:packages, :reservation_text, :substances
		attr_accessor :category
		def initialize
			@packages = []
			@substances = []
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
		end
		def create_reservation_text
			@reservation_text = Text::Document.new
		end
		def pointer_descr
			to_s
		end
		def remove_package(package)
			if(@packages.delete(package))
				@packages.odba_isolated_store
				package
			end
		end
		def remove_substance(substance)
			if(sub = @substances.delete(substance))
				@substances.odba_store
				sub
			end
		end
		def search_terms
			@substances.inject([]) { |terms, sub|
				terms + sub._search_keys
			}
		end
		def swissmedic_code 
			@substance.swissmedic_code unless(@substance.nil?)
		end
		def to_s
			@substances.sort_by { |sub| 
				sub.to_s
			}.join(',')
		end
	end
end
