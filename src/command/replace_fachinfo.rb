#!/usr/bin/env ruby
# ReplaceFachinfoCommand -- ODDB -- 14.11.2003 -- hwyss@ywesee.com

module ODDB
	class ReplaceFachinfoCommand
		def initialize(iksnr, pointer)
			@iksnr = iksnr
			@pointer = pointer
		end
		def execute(app)
			if((registration = app.registration(@iksnr)) \
				&& (fachinfo = @pointer.resolve(app)))
				old_fi = registration.fachinfo
				registration.fachinfo = fachinfo
				if(old_fi && old_fi.empty?)
					#puts "========= deleting #{old_fi.pointer} ========"
					app.delete(old_fi.pointer)
					#puts "========== piece of cake ============="
				end
				nil
			end
		end
	end
end
