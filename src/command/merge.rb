#!/usr/bin/env ruby
# MergeGalenicFormCommand -- oddb -- 09.04.2003 -- hwyss@ywesee.com 

module ODDB
	class MergeCommand
		def initialize(source_pointer, target_pointer)
			@source_pointer, @target_pointer = source_pointer, target_pointer
		end
		def execute(app)
			source = @source_pointer.resolve(app)
			target = @target_pointer.resolve(app)
			ODBA.batch { 
				target.merge(source)
				app.delete(@source_pointer)
			}
			nil
		end
	end
end
