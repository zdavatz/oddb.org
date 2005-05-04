#!/usr/bin/env ruby
# View::DataFormat -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

module ODDB
	module View
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
				value = model.send(key).to_i
				if(value != 0)
					price = HtmlGrid::NamedComponent.new(key, model, @session, self)
					price.value = @lookandfeel.format_price(value)
					price.label = true
					price
				else
					link = HtmlGrid::Link.new(:price_request, model, @session, self)
					pagenames = {
						'de'	=>	'PreisAnfrage',
						'en'	=>	'PriceRequest',
						'fr'	=>	'DemandeDesPrix',
					}
					pagename = pagenames[@lookandfeel.language]
					link.href = "http://wiki.oddb.org/wiki.php?n=ODDB.#{pagename}"
					link
				end
			end
		end
	end
end
