#!/usr/bin/env ruby
# Language -- oddb -- 24.03.2003 -- maege@ywesee.com 

require 'util/persistence'

module ODDB
	module SimpleLanguage
		include Persistence
		class Descriptions < Hash
			def initialize
				super('')
			end
			def to_hash # mostly for testing purposes...
				inject({}) { |inj, pair|
					inj.store(*pair)
					inj
				}
			end
			def update_values(values)
				if(self.default.nil? || self.default.empty?)
					self.default = values.sort.first.at(1) unless values.empty?
				else
					key = index(self.default)
					self.default = values[key] if values.include?(key)
				end
				update(values)
			end
		end
		def description(key=nil)
			descriptions[key]
		end
		def descriptions
			@descriptions ||= Descriptions.new
		end
		def has_description?(description)
			descriptions.has_value?(description)
		end
		def method_missing(symbol, *args)
			language = symbol.to_s
			if(language.length == 2)
				descriptions[language]
			else
				super
				#raise NoMethodError.new("Undefined or Private Method: #{language} for #{self.class}:#{self}")
			end
		end
		def respond_to?(symbol)
			symbol.to_s.length == 2 || super
		end
		def to_s
			descriptions.default.to_s
		end
		def update_values(values)
			values = values.dup
			descr = values.keys.inject({}) { |inj, key|
				inj.store(key.to_s, values.delete(key)) if(key.to_s.length==2)
				inj
			}
			descriptions.update_values(descr)
			super(values)
		end
		alias :pointer_descr :description
		alias :name :to_s
	end
	module Language
		include SimpleLanguage
		class Descriptions < Hash
			def initialize
				super('')
			end
			def to_descriptions
				desc = SimpleLanguage::Descriptions.new
				desc.update_values(to_hash)
				desc
			end
			def to_hash # mostly for testing purposes...
				inject({}) { |inj, pair|
					inj.store(*pair)
					inj
				}
			end
			def update_values(values)
				if(self.default.nil? || self.default.empty?)
					self.default = values.sort.first.at(1) unless values.empty?
				else
					key = index(self.default)
					self.default = values[key] if values.include?(key)
				end
				update(values)
			end
		end
		def init(app=nil)
			super
=begin
			last_step = @pointer.last_step
			last_step.push(@oid) if last_step.size == 1
			@pointer = if(@pointer.parent)
				@pointer.parent + last_step
			else
				Persistence::Pointer.new(last_step)
			end
=end
			unless(@pointer.last_step.size > 1)
				@pointer.append(@oid) 
			end
			@pointer
		end
	end
end
