#!/usr/bin/env ruby
# -- oddb -- 02.11.2004 -- jlang@ywesee.com

require 'util/persistence'

module ODDB
	class Feedback
		include Persistence
		attr_accessor :name, :email, :message, :experience, :recommend, :impression, :helps, :time
		def init(app=nil)
			super
			@pointer.append(@oid)
		end
	end
end
