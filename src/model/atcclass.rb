#!/usr/bin/env ruby
# AtcClass -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/language'
require 'util/persistence'
require 'util/searchterms'
require 'model/text'
require 'model/sequence_observer'

module ODDB
	class AtcClass
		include Language
		include SequenceObserver
		ODBA_SERIALIZABLE = [ '@descriptions' ]
		attr_accessor :code
		attr_reader :guidelines, :ddd_guidelines
		# use this instead of add_sequence for temporary atc_classes
		attr_writer :sequences, :descriptions
		class DDD
			include Persistence
			attr_accessor :dose, :note, :administration_route
			def initialize(roa)
        @key = roa
				@administration_route = roa[0,1]
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
			@sequences.inject([]) { |inj, seq| inj.concat(seq.public_packages) }
		end
		def package_count(generic_type=nil)
			@sequences.inject(0) { |inj, seq|
				inj + seq.public_package_count(generic_type)
			}
		end
		def checkout
			@sequences.dup.each { |seq| seq.atc_class = nil } 
			@sequences.odba_delete
		end
    def company_filter_search(company_name)
      filter_proc = Proc.new do |seq|
        ODDB.search_term(seq.company.to_s.downcase).include?(company_name)
      end
      filter filter_proc
    end
		def create_ddd(roa)
			ddds[roa] = DDD.new(roa)	
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
			ddds[roa]
		end
		def ddds
			@ddds ||= {}
		end
    def delete_ddd(roa)
      if(ddd = @ddds.delete(roa))
        @ddds.odba_isolated_store
				ddd
			end
    end
    def filter filter_proc
      atc = self.dup
      atc.sequences = @sequences.select do |seq|
        filter_proc.call seq
      end
      atc
    end
		def packages
			@sequences.collect { |seq| seq.packages.values }.flatten
		end
		def substances
			@sequences.collect { |seq| seq.substances 
			}.flatten.uniq
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
	end
end
