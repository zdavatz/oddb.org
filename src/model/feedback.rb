#!/usr/bin/env ruby
# Feedback -- oddb -- 02.11.2004 -- jlang@ywesee.com

require 'util/persistence'

module ODDB
	class Feedback
		include Persistence
		attr_accessor :name, :email, :message, :show_email, :experience, :recommend, :impression, :helps, :time
		attr_writer :oid
		def init(app=nil)
			super
			@pointer.append(@oid)
		end
	end
end
