#!/usr/bin/env ruby
# UpdateCommand -- oddb -- 08.08.2003 -- hwyss@ywesee.com 

module ODDB
	class UpdateCommand
		def initialize(pointer, values, origin = nil)
			@pointer = pointer
			@values = values
			@origin = origin
		end
		def execute(app)
			app.update(@pointer, @values, @origin)
		end
	end
end
