#!/usr/bin/env ruby
# View::ResultColors -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

module ODDB
	module View
		module ResultColors
=begin
			@@expired ||= {}
			@midnight_walker ||= Thread.new {
				loop {
					tomorrow = @@today + 1
					midnight = Time.local(tomorrow.year, tomorrow.month, tomorrow.day)
					sleep(midnight - Time.now)
					@@expired.clear
				}
			}
=end
			private
			def resolve_suffix(model, bg_flag=false)
				gt = model.generic_type || 'unknown'
				' ' << gt.to_s << super
			end
			def row_css(model)
				'expired' if(model.respond_to?(:expired?) && model.expired?)
=begin
				if(model.respond_to?(:iksnr))
					iksnr = model.iksnr
					exp = @@expired[iksnr] ||= model.expired?
				end
=end
			end
		end
	end
end
