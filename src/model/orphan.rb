#!/usr/bin/env ruby
# OrphanedPatinfo -- oddb -- 06.11.2003 -- rwaltert@ywesee.com

require 'util/persistence'
require 'util/language'

module ODDB
	class OrphanedPatinfo
		attr_accessor :reason, :meanings, :key
		alias :pointer_descr :key
		include Persistence
		def init(app=nil)
			super
			unless(@pointer.last_step.size > 1)
				@pointer.append(@oid) 
			end
		end
		def names
			@meanings.compact!
			@meanings.collect { |languages|
				begin
					languages.sort.first.last.name
				rescue StandardError => e
					e.message
				end
			}.join(', ')
		end
	end
	class OrphanedFachinfo
		attr_accessor :key, :languages
		alias :pointer_desc :key
		include Persistence
		def init (app=nil)
			super
			unless (@pointer.last_step.size > 1)
				@pointer.append(@oid)
			end
		end
		def name
			begin
				@languages.sort.first.last.name
			rescue StandardError => e
				e.message
			end
		end
	end
	class PatinfoDeprivedSequences
		def name
			begin
				model.name
			rescue StandardError => e
				e.message
			end
		end
	end
end
