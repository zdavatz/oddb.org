#!/usr/bin/env ruby
# AcceptIncompleteRegistration -- oddb -- 23.06.2003 -- hwyss@ywesee.com 

module ODDB
	class AcceptIncompleteRegistration
		def initialize(pointer)
			@pointer = pointer
		end
		def execute(app)
			incomplete = @pointer.resolve(app)
			incomplete.accepted!(app)
		end
	end
end
