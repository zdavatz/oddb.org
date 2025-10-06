#!/usr/bin/env ruby

# ODDB::Language -- oddb -- 08.05.2013 -- yasaka@ywesee.com
# ODDB::Language -- oddb -- 24.03.2003 -- mhuggler@ywesee.com

require "util/persistence"
require "util/logfile"
module ODDB
  module SimpleLanguage
    include Persistence
    class Descriptions < Hash
      def to_hash # mostly for testing purposes...
        each_with_object({}) { |pair, inj|
          inj.store(*pair)
        }
      end

      def update_values(values, origin = nil)
        update(values)
      end

      def first
        if empty?
          ""
        else
          sort.first.last
        end
      end
    end

    def description(key = nil)
      if @descriptions
        begin
          if @descriptions.is_a?(Array) || @descriptions[key].nil?
            descriptions.keys.each do |key|
              if key.is_a?(Symbol) && descriptions[key.to_s]
                LogFile.debug "Deleted #{key.inspect} for #{@descriptions&.values&.first&.to_s[0..40]}"
                descriptions.delete(key)
                odba_store
              end
            end
            @descriptions.first
          else
            @descriptions[key]
          end
        rescue ODBA::OdbaError, NoMethodError => error
          LogFile.debug "Descriptions.description error #{error.inspect}"
          #          puts caller[0..10].join("\n")
          ""
        end
      else
        ""
      end
    end

    def descriptions
      @descriptions ||= Descriptions.new
    end

    def has_description?(description)
      descriptions.has_value?(description)
    end

    def match(pattern)
      descriptions.values.any? { |desc| pattern.match(desc) }
    end

    def method_missing(symbol, *args, &block)
      language = symbol.to_s
      if language.length == 2
        description(language)
      else
        super
      end
    end

    def respond_to?(symbol, *args)
      symbol.to_s.length == 2 || super
    end

    def search_text(language)
      ODDB.search_term(send(language).to_s)
    end

    def to_s
      if !descriptions.respond_to?(:empty?) or descriptions.empty?
        ""
      else
        descriptions.first.to_s
      end
    end

    def update_values(values, origin = nil)
      values = values.dup
      descr = values.keys.each_with_object({}) { |key, inj|
        inj.store(key.to_s, values.delete(key)) if key.to_s.length == 2
      }
      descriptions.update_values(descr)
      super
    end
    alias_method :pointer_descr, :description
    alias_method :name, :to_s
  end

  module Language
    include SimpleLanguage
    class Descriptions < SimpleLanguage::Descriptions
    end

    def init(app = nil)
      super
      unless @pointer.last_step.size > 1
        @pointer.append(@oid)
      end
      @pointer
    end

    def all_descriptions
      synonyms + descriptions.values
    end

    def has_description?(descr)
      super || (@synonyms.is_a?(Array) && @synonyms.include?(descr))
    end

    def synonyms
      @synonyms ||= []
    end

    def synonyms=(syns)
      @synonyms = syns.compact.delete_if { |syn| syn.empty? }
    end
  end
end
