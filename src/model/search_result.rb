#!/usr/bin/env ruby
# SearchResult -- oddb -- 08.07.2004 -- mwalder@ywesee.com , rwaltert@ywesee.com

require 'model/atcclass'
require 'util/resultsort'
require 'delegate'

module ODDB
	class AtcFacade
		include ResultSort
		def initialize(atc, session, result)
			@atc = atc
			@session = session
			#@package_count = @packages.size
			@packages_sorted = false
      @result = result
		end
		def active_packages
			@packages ||= @atc.active_packages
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
    def overflow?
      @result.overflow?
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
		def parent_code
			@atc.parent_code
		end
		def sequences
			@atc.sequences
		end
	end
	class SearchResult
    include Enumerable
		attr_accessor  :atc_classes, :session, :relevance, :exact, 
			:search_type, :search_query, :limit
		def initialize
      @limit = 50
			@relevance = {}
		end
		def atc_facades
			@atc_facades ||= @atc_classes.collect { |atc_class|
				AtcFacade.new(atc_class, @session, self)
			}
		end
		def atc_sorted
			@atc_sorted or begin 
        if(overflow?)
          @atc_sorted = atc_facades.sort_by { |atc| 
            atc.description
          }
        elsif(@relevance.empty?)
          case @search_type
          when :substance
            @atc_sorted = atc_facades.sort_by { |atc_class|
              atc_class.packages.select { |pac|
                pac.active_agents.any? { |act| 
                  act.same_as?(@query)
                }
              }.size
            }
          else
            @atc_sorted = atc_facades.sort_by { |atc_class|
              atc_class.package_count.to_i
            }
          end
          @atc_sorted.reverse!
        else 
          case @search_type
          when :interaction, :unwanted_effect
            @atc_sorted = atc_facades.sort_by { |atc| 
              count = atc.sequences.size
              atc.sequences.inject(0) { |sum, seq|
                sum + @relevance[seq.odba_id].to_f } / count
            }
          else
            @atc_sorted = atc_facades.sort_by { |atc_class|
              count = atc_class.package_count.to_i
              @relevance[atc_class.odba_id].to_f / count
            }
          end
          @atc_sorted.reverse!
        end
        delete_empty_packages(@atc_sorted)
      rescue Exception => e
        puts e.message
        puts e.backtrace
        atc_facades
      end
    end
		def each(&block)
			self.atc_sorted.each(&block)
		end
    def empty?
      @atc_classes.nil? || @atc_classes.empty?
    end
    def filter! filter_proc
      @atc_classes = @atc_classes.collect do |atc|
        atc.filter filter_proc
      end
    end
    def overflow?
      (@atc_classes.size > 1) && (package_count >= @limit)
    end
    def package_count
      @package_count ||= @atc_classes.inject(0) { |count, atc| 
        count + atc.package_count }
    end
		def set_relevance(odba_id, relevance)
			@relevance[odba_id] = @relevance[odba_id].to_f + relevance.to_f
		end
		private
		def delete_empty_packages(atc_classes)
			atc_classes.delete_if { |atc|
				atc.active_packages.empty?
			}
		end
	end
end
