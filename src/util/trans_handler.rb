#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TransHandler -- oddb.org -- 26.06.2012 -- yasaka@ywesee.com

require 'sbsm/trans_handler'
require 'singleton'

module ODDB
	class AbstractTransHandler < SBSM::AbstractTransHandler
		def handle_shortcut(request, config)
      unless shortcut = super
        # shorten_path handling
        if request.uri =~ /^\/([^\/\.]+)$/
          request.notes.add('event', 'shorten_path')
				  request.uri = HANDLER_URI
        end
      end
    end
  end
	class TransHandler < AbstractTransHandler
		include Singleton
		def initialize
			super('uri')
		end
	end
	class FlavoredTransHandler < AbstractTransHandler
		include Singleton
		def initialize
			super('flavored_uri')
		end
	end
	class ZoneTransHandler < AbstractTransHandler
		include Singleton
		def initialize
			super('zone_uri')
		end
	end
end
