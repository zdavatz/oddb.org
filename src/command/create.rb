#!/usr/bin/env ruby
# encoding: utf-8
# CreateCommand -- oddb -- 08.08.2003 -- hwyss@ywesee.com 

module ODDB
	class CreateCommand
		def initialize(pointer)
			@pointer = pointer
		end
		def execute(app)
			app.create(@pointer)
		end
	end
end
