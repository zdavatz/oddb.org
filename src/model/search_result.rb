#!/usr/bin/env ruby
# SearchResult -- oddb -- 08.07.2004 -- mwalder@ywesee.com , rwaltert@ywesee.com
require 'model/atcclass'
require 'util/resultsort'
require 'delegate'

module ODDB
	class AtcFacade
		include ResultSort
		attr_reader :packages, :package_count
		def initialize(atc, session)
			@atc = atc
			@session = session
			#@package_count = @packages.size
			@packages_sorted = false
		end
		def active_packages
			@atc.active_packages
		end
		def description(*args)
			@atc.description(*args)
		end
		def code
			@atc.code
		end
		def odba_id
			@atc.odba_id
		end
		def empty?
			self.packages.empty?
		end
		def has_ddd?
			@atc.has_ddd?
		end
		def pointer
			@atc.pointer
		end
		def packages
			@packages ||= @atc.active_packages
			unless(@packages_sorted)
				@packages = sort_result(@packages, @session)
				@packages_sorted = true
			end
			@packages
		end
		def package_count(generic_type=nil)
			@atc.package_count(generic_type)
		end
	end
	class SearchResult
		attr_accessor  :atc_classes, :session, :relevance
		def initialize
			@relevance = {}
		end
		def atc_facades
			@atc_facades ||= @atc_classes.collect { |atc_class|
				AtcFacade.new(atc_class, @session)
			}
		end
		def atc_sorted
			@atc_facades = if(@relevance.empty?)
				atc_facades.sort_by { |atc_class|
					atc_class.package_count.to_i
				}
			else
				@atc_facades = atc_facades.sort_by { |atc_class|
					[
						@relevance[atc_class.odba_id].to_f, 
						atc_class.package_count(:complementary).to_i,
						atc_class.package_count.to_i,
					]
				}
			end
			@atc_facades.reverse!
			delete_empty_packages(@atc_facades)
		end
		def each(&block)
			self.atc_sorted.each(&block)
		end
		def set_relevance(odba_id, relevance)
			@relevance.store(odba_id, relevance)
		end
		private
		def delete_empty_packages(atc_classes)
			atc_classes.delete_if { |atc|
				atc.active_packages.empty?
			}
		end
	end
end
