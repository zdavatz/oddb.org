#!/usr/bin/env ruby
# DataFormat -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

module ODDB
	module DataFormat
		def price_exfactory(model, session)
			#@lookandfeel.format_price(model.price_exfactory)
			formatted_price(:price_exfactory, model)
		end
		def price_public(model, session)
			#@lookandfeel.format_price(model.price_public)
			formatted_price(:price_public, model)
		end
		private
		def formatted_price(key, model)
			price = HtmlGrid::NamedComponent.new(key, model, @session, self)
			price.value = @lookandfeel.format_price(model.send(key))
			price.label = true
			price
		end
	end
end
