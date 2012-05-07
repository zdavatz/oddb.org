#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::ResultColors -- oddb -- 07.05.2012 -- yasaka@ywesee.com
# ODDB::View::ResultColors -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

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
        # only Package#sl_generic_type
				gt = model.respond_to?(:sl_generic_type) ? model.sl_generic_type : 'unknown'
				' ' << gt.to_s << super
			end
			def row_css(model, bg_flag=false)
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
