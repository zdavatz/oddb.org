#!/usr/bin/env ruby

# ODDB::SearchResult -- oddb.org -- 22.06.2012 -- yasaka@ywesee.com
# ODDB::SearchResult -- oddb.org -- 08.07.2004 -- mwalder@ywesee.com , rwaltert@ywesee.com

require "model/atcclass"
require "util/resultsort"
require "delegate"

module ODDB
  class AtcFacade
    include ResultSort
    attr_reader :atc
    attr_accessor :packages
    def initialize(atc, session, result)
      @atc = atc
      @session = session
      @packages_sorted = false
      @result = result
    end

    def filter filter_proc
      @atc.sequences = @atc.sequences.select do |seq|
        filter_proc.call seq
      end
      @atc
    end

    def active_packages
      @packages ||= @atc.packages.select { |pack| !pack.expired? }
    end

    def code
      @atc.code
    end

    def description(*args)
      @atc.description(*args)
    end

    def odba_id
      @atc.odba_id
    end

    def empty?
      packages.empty?
    end

    def has_ddd?
      @packages ||= active_packages
      !!@packages.find { |x| x.ddd }
    end

    def overflow?
      @result.overflow?
    end

    def pointer
      @atc.pointer
    end

    def packages
      @packages ||= @atc.packages
      unless @packages_sorted
        @packages = sort_result(@packages, @session)
        @packages_sorted = true
      end
      @packages
    end

    def package_count(generic_type = nil)
      packages.size
    end

    def parent_code
      @atc.parent_code
    end

    def db_id
      @atc.db_id
    end

    def ni_id
      @atc.ni_id
    end

    def sequences
      @atc.sequences.find_all { |sequence| sequence.active? }
    end
  end

  class SearchResult
    include Enumerable
    attr_accessor :atc_classes, :session, :relevance, :exact,
      :search_type, :search_query, :limit, :display_limit, :error_limit,
      :package_filters, :sequence_filter

    def initialize(package_filters: {})
      @display_limit = 50
      @package_filters = package_filters
      @relevance = {}
      @atc_classes = []
    end

    def atc_facades(session = nil)
      @session = session
      @atc_facades ||= @atc_classes.collect do |atc_class|
        AtcFacade.new(atc_class, session, self)
      end

      @atc_facades
    end

    def atc_sorted
      atc_facades(@session)
      @atc_sorted or begin
        if overflow?
          @atc_sorted = @atc_facades.sort_by { |atc|
            atc.description
          }
        elsif @relevance.empty?
          @atc_sorted = case @search_type
          when :substance
            @atc_facades.sort_by { |atc_class|
              atc_class.packages.select { |pac|
                pac.active_agents.any? { |act|
                  act.same_as?(@search_query)
                }
              }.size
            }
          else
            @atc_facades.sort_by { |atc_class|
              atc_class.package_count.to_i
            }
          end
          @atc_sorted.reverse!
        else
          @atc_sorted = case @search_type
          when :interaction, :unwanted_effect
            @atc_facades.sort_by { |atc|
              count = atc.sequences.size
              if count > 0
                atc.sequences.inject(0) { |sum, seq|
                  sum + @relevance[seq.odba_id].to_f
                } / count
              end
            }
          else
            @atc_facades.sort_by do |atc_class|
              count = atc_class.package_count.to_i
              @relevance[atc_class.odba_id].to_f / count
            end
          end
          @atc_sorted.reverse!
        end
        delete_empty_packages(@atc_sorted)
      rescue => e
        puts e.message
        puts e.backtrace
        atc_facades
      end
    end

    def each(&block)
      atc_sorted.each(&block)
    end

    def empty?
      @atc_classes.nil? || @atc_classes.empty?
    end

    def sequence_filter(session = nil)
      @session = session
      @packages = []
      @atc_facades = nil
      @atc_facades = atc_facades(session)
      @atc_facades = @atc_facades.collect do |atc|
        if @sequence_filter
          sequences = atc.atc.sequences.select { |pack| @sequence_filter.call pack }
          packs = sequences.collect { |seq| seq.packages.values }.flatten
          atc.packages = packs
          @packages << packs
          sequences.empty? ? nil : atc
        else
          packs = atc.atc.sequences.collect { |seq| seq.packages.values }
          @packages << packs
          atc
        end
      end.compact
      @packages.flatten!
      @package_count = nil
      @atc_facades
    end

    def apply_filters(session = nil)
      @session = session
      sequence_filter(session)
      filtered = []
      @atc_facades.each do |facade|
        @package_filters.each do |key, filter_proc|
          facade.packages = facade.packages.select { |pack| filter_proc.call pack }
          filtered << facade.packages
        end
      end
      @packages = filtered

      @packages.flatten!
      @package_count = nil
    rescue => error
      puts "Error #{error} in apply_filters"
      puts error.backtrace[0..5].join("\n")
    end

    def overflow?
      (@atc_classes.size > 1) && (package_count >= @display_limit)
    end

    def package_count
      @package_count = atc_facades(@session).inject(0) { |count, atc|
        count + atc.packages.size
      }
    end

    def set_relevance(odba_id, relevance)
      @relevance[odba_id] = @relevance[odba_id].to_f + relevance.to_f
    end

    private

    def delete_empty_packages(atc_classes)
      atc_classes.delete_if { |atc|
        atc.packages.empty?
      }
    end
  end
end
