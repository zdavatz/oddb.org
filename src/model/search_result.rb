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
			#puts "ATCFacade::empty?"
			self.packages.empty?
		end
		def has_ddd?
			@atc.has_ddd?
		end
		def pointer
			@atc.pointer
		end
		def packages
			#puts "ATCFacade::packages"
			@packages ||= @atc.active_packages
			unless(@packages_sorted)
				@packages = sort_result(@packages, @session)
				@packages_sorted = true
			end
			@packages
		end
		def package_count
			#puts "ATCFacade::package_count"
			@atc.package_count
		end
	end
	class SearchResult
		include ResultSort
		attr_accessor  :atc_classes, :session, :relevance
		def initialize
			@relevance = {}
		end
		def atc_facades
			@atc_facades ||= @atc_classes.collect { |atc_class|
				AtcFacade.new(atc_class, @session)
			}
		end
		def each(&block)
			self.atc_sorted.each(&block)
		end
		def set_relevance(odba_id, relevance)
			@relevance.store(odba_id, relevance)
		end
		def atc_sorted
			@atc_facades = atc_facades.sort_by { |atc_class|
			[
					@relevance[atc_class.odba_id].to_f, 
					atc_class.package_count.to_i
				]
			}.reverse
			delete_empty_packages(@atc_facades)
		end
=begin
		def get_by_relevance
			by_relevance = []
			relevance = Hash.new
			@relevance.each { |result_set|
				atc_id = result_set.at(0)
				atc_relevance = result_set.at(1)
				@atc_classes.each{ |atc|
					if (atc.odba_id == atc_id)
						if(relevance.has_key?(atc_relevance))
							atc_arr = relevance.fetch(atc_relevance)
							atc_arr.push(atc)
						else
							relevance.store(atc_relevance, [atc])
						end
					end
				}
			}
			tmp_relevance = relevance.sort.reverse
			tmp_relevance.each{ |atc_set|
				sorted = sort_by_package_count(atc_set.at(1))
				by_relevance.push(sorted)
			}
			by_relevance.flatten
		end
=end
		private
		def delete_empty_packages(atc_classes)
			atc_classes.delete_if { |atc|
				atc.active_packages.empty?
			}
		end
	end
end
