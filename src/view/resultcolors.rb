#!/usr/bin/env ruby
# ResultColors -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

module ODDB
	module ResultColors
		private
		def resolve_suffix(model, bg_flag=false)
			gt = model.generic_type || 'unknown'
			'-' + gt.to_s + super
		end
	end
end
