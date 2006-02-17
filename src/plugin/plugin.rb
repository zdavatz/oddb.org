#!/usr/bin/env ruby
# Plugin -- oddb -- 30.05.2003 -- hwyss@ywesee.com 

require 'util/http'

module ODDB
	class Plugin
		include HttpFile
		ARCHIVE_PATH = File.expand_path('../../data', File.dirname(__FILE__))
		# Recipients for Plugin-Specific Update-Logs can be added in 
		# 'Plugin's subclasses
		RECIPIENTS = []
		attr_reader :change_flags, :month
		def initialize(app)
			@app = app
			@change_flags = {}
		end
		def log_info
			[:change_flags, :report, :recipients].inject({}) { |inj, key|
				inj.store(key, self.send(key))
				inj
			}
		end
		def recipients
			self::class::RECIPIENTS
		end
		def report
			''
		end
		def resolve_link(model)
			pointer = model.pointer
			str = if(model.respond_to?(:name_base)) 
				(model.name_base.to_s + ': ').ljust(50) 
			else
				''
			end
			str << 'http://www.oddb.org/de/gcc/resolve/pointer/' << CGI.escape(pointer.to_s) << ' '
		rescue Exception
			"Error creating Link for #{pointer.inspect}"
		end
	end
end
