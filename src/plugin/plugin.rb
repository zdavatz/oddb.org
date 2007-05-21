#!/usr/bin/env ruby
# Plugin -- oddb -- 30.05.2003 -- hwyss@ywesee.com 

require 'util/http'
require 'ostruct'
require 'util/session'
require 'custom/lookandfeelbase'

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
    def l10n_sessions(&block)
      stub = OpenStruct.new
      stub.flavor = Session::DEFAULT_FLAVOR
      stub.http_protocol = 'http'
      stub.server_name = SERVER_NAME
      stub.app = @app
      LookandfeelBase::DICTIONARIES.each_key { |lang|
        stub.language = lang
        stub.lookandfeel = LookandfeelBase.new(stub)
        block.call(stub)
      }
    end
		def log_info
			[:change_flags, :report, :recipients].inject({}) { |inj, key|
				inj.store(key, self.send(key))
				inj
			}
		end
		def recipients
			@recipients || self::class::RECIPIENTS
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
