#!/usr/bin/env ruby
# AcceptIncompleteRegistration -- oddb -- 23.06.2003 -- hwyss@ywesee.com 

module ODDB
	class AcceptIncompleteRegistration
		def initialize(pointer)
			@pointer = pointer
		end
		def execute(app)
			incomplete = @pointer.resolve(app)
			ODBA.transaction {
				incomplete.accepted!(app)
			}
			app.recount
		end
	end
end
