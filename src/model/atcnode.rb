#!/usr/bin/env ruby
# ODDB::AtcNote -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com
# ODDB::AtcNode -- oddb.org -- 17.07.2003 -- mhuggler@ywesee.com

module ODDB
	class AtcNode
		attr_reader :children
		def initialize(atcclass)
			@atc_class = atcclass
			@children = []
		end
		def method(name)
			begin
				super
			rescue NameError
				@atc_class.method(name)
			end
		end
		def method_missing(*args)
			@atc_class.send(*args) unless @atc_class.nil?
		end
		def add_offspring(atc_node)
			nextnode = @children.select { |node| 
				node.path_to?(atc_node.code) 
			}.first
			unless(nextnode.nil?)
				nextnode.add_offspring(atc_node)
			else
				@children.push(atc_node)
			end
		end
		def delete(atc_code)
			@children.delete_if { |node| node.code == atc_code }
			@children.each { |node| 
				node.delete(atc_code) if node.path_to?(atc_code)
			}
		end
		def each(&block)
			block.call(self)
			children.each(&block)
		end
		def has_sequence?
			(!@atc_class.nil? && !@atc_class.sequences.empty?) \
			|| @children.any? { |node|
				node.has_sequence?	
			}
		end
		def level
			return 0 if @atc_class.nil?
			@atc_class.level
		end
		def path_to?(atccode)
			return true if @atc_class.nil?
			return false if atccode.nil?
			cd = @atc_class.code
			begin
				atccode.length >= cd.length \
					&& cd == atccode[0,cd.length]
			rescue
        nil
			end
		end
	end
end
