#!/usr/bin/env ruby
# AtcClass -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'util/language'
require 'model/text'
require 'model/sequence_observer'

module ODDB
	class AtcClass
		include Language
		include SequenceObserver
		ODBA_PREFETCH = true
		attr_accessor :code
		attr_reader :guidelines, :ddd_guidelines
		class DDD
			include Persistence
			attr_accessor :dose, :note
			attr_reader :administration_route
			def initialize(roa)
				@administration_route = roa
			end
			def ==(other)
				if(other.is_a? Hash)
					@dose == other[:dose] && @note == other[:note] \
						&& @administration_route == other[:administration_route]
				elsif(other.is_a? DDD)
					@dose == other.dose && @note == other.note \
						&& @administration_route == other.administration_route
				else
					false
				end
			end
		end
		def initialize(code)
			@code = code
			@ddds = {}
			super()
		end
		def active_packages
			@sequences.collect { |seq| seq.active_packages }.flatten
		end
		def checkout
			@sequences.each { |seq| seq.atc_class = nil } 
		end
		def company_filter(companies)
			atc = self.dup
			atc.sequences = @sequences.select { |seq| 
				companies.include?(seq.company)
			}
			atc
		end
		def create_ddd(roa)
			@ddds ||= {}
			@ddds[roa] = DDD.new(roa)	
		end
		def create_ddd_guidelines
			@ddd_guidelines = Text::Document.new
		end
		def create_guidelines
			@guidelines = Text::Document.new
		end
		def has_ddd?
			!!(@guidelines || @ddd_guidelines || !ddds.empty?)
		end
		def level
			len = @code.length		
			if(len == 7)
				5
			elsif(len > 2)
				len-1
			else
				len
			end
		end
		def ddd(roa)
			@ddds ||= {}
			@ddds[roa]
		end
		def ddds
			@ddds ||= {}
		end
		def packages
			@sequences.collect { |seq| seq.packages.values }.flatten
		end
		def parent_code
			case level
			when 2
				@code[0,1]
			when 3, 4, 5
				@code[0,level]
			end
		end
		def pointer_descr(key=nil)
			[super,'(' + @code + ')'].compact.join(' ')
		end
		protected
		attr_writer :sequences
	end
end
