#!/usr/bin/env ruby
# View::ResultColors -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

module ODDB
	module View
		module ResultColors
			@@expired ||= {}
			@midnight_walker ||= Thread.new {
				loop {
					tomorrow = Date.today + 1
					midnight = Time.local(tomorrow.year, tomorrow.month, tomorrow.day)
					sleep(midnight - Time.now)
					@@expired.clear
				}
			}
			private
			def resolve_suffix(model, bg_flag=false)
				exp = false
				if(model.respond_to?(:iksnr))
					iksnr = model.iksnr
					exp = @@expired[iksnr] ||= model.expired?
				end
				gt = model.generic_type || 'unknown'
				es = exp ? ' expired' : ''
				'-' + gt.to_s + super + es
			end
		end
	end
end
