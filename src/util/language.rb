#!/usr/bin/env ruby
# Language -- oddb -- 24.03.2003 -- mhuggler@ywesee.com 

require 'util/persistence'

module ODDB
	module SimpleLanguage
		include Persistence
		class Descriptions < Hash
			def to_hash # mostly for testing purposes...
				inject({}) { |inj, pair|
					inj.store(*pair)
					inj
				}
			end
			def update_values(values, origin=nil)
				update(values)
			end
      def first
        if empty?
          ''
        else
          sort.first.last
        end
      end
		end
		def description(key=nil)
			descriptions[key.to_s] || descriptions.first
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
			if(language.length == 2)
				description(language)
			else
				super
			end
		end
		def respond_to?(symbol, *args)
			symbol.to_s.length == 2 || super
		end
    def search_text(language)
      ODDB.search_term(self.send(language).to_s)
    end
		def to_s
      if descriptions.empty?
        ''
      else
        descriptions.first.to_s
      end
		end
		def update_values(values, origin=nil)
			values = values.dup
			descr = values.keys.inject({}) { |inj, key|
				inj.store(key.to_s, values.delete(key)) if(key.to_s.length==2)
				inj
			}
			descriptions.update_values(descr)
			super(values, origin)
		end
		alias :pointer_descr :description
		alias :name :to_s
	end
	module Language
		include SimpleLanguage
		class Descriptions < SimpleLanguage::Descriptions
    end
		def init(app=nil)
			super
			unless(@pointer.last_step.size > 1)
				@pointer.append(@oid) 
			end
			@pointer
		end
		def all_descriptions
			self.synonyms + self.descriptions.values
		end
		def has_description?(descr)
			super || (@synonyms.is_a?(Array) && @synonyms.include?(descr))
		end
		def synonyms
			@synonyms ||= []
		end
		def synonyms=(syns)
			@synonyms = syns.compact.delete_if { |syn| syn.empty?  }
		end
	end
end
