#!/usr/bin/env ruby
# encoding: utf-8
# Narcotic -- oddb -- 04.11.2005 -- ffricker@ywesee.com

require 'util/persistence'
require 'util/language'
require 'model/package_observer'
require 'model/text'

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
      (subst = @substances.find do |sub| sub.casrn end) && subst.casrn
		end
		def checkout
			@substances.dup.each { |sub| 
				sub.narcotic = nil 
				sub.odba_store
			}
      @substances.odba_delete
			@packages.dup.each { |pack| 
				pack.remove_narcotic(self)
				pack.odba_store 
			}
      @packages.odba_delete
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
		def swissmedic_codes
			@substances.collect { |sub| sub.swissmedic_code }
		end
    alias :swissmedic_code :swissmedic_codes
		def to_s
      @substances.collect do |sub| sub.to_s end.sort.first
		end
	end
end
