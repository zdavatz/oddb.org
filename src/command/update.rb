#!/usr/bin/env ruby
# UpdateCommand -- oddb -- 08.08.2003 -- hwyss@ywesee.com 

module ODDB
	class UpdateCommand
		def initialize(pointer, values)
			@pointer = pointer
			@values = values
		end
		def execute(app)
			ODBA.batch { 
				app.update(@pointer, @values)
			}
		end
	end
end
