#!/usr/bin/env ruby
# DeleteCommand -- oddb -- 08.08.2003 -- hwyss@ywesee.com 

module ODDB
	class DeleteCommand
		def initialize(pointer)
			@pointer = pointer
		end
		def execute(app)
			app.delete(@pointer)
		end
	end
end
