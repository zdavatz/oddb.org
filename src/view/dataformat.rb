#!/usr/bin/env ruby
# View::DataFormat -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'plugin/fxcrossrate'

module ODDB
	module View
		module DataFormat
			def price_exfactory(model, session)
				formatted_price(:price_exfactory, model)
			end
			def price_public(model, session)
				formatted_price(:price_public, model)
			end
			private
			def formatted_price(key, model)
				value = model.send(key).to_i
				if(value != 0)
					price_chf = model.send(key).to_i
					price_euro = price_to_euro(price_chf)
					price_usd = price_to_usd(price_chf)
					span = HtmlGrid::Span.new(model, @session, self)
					price = HtmlGrid::NamedComponent.new(key, model, @session, self)
					price.value = @lookandfeel.format_price(value)
					price.label = true
					span.value = price
					span.set_attribute('title', "USD: #{price_usd} / EURO: #{price_euro}")
					span
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
			def price_to_euro(price)
				result = price * @session.get_currency_rate('EUR')
				@lookandfeel.format_price(result)
			end
			def price_to_usd(price)
				result = price * @session.get_currency_rate('USD')
				@lookandfeel.format_price(result)
			end
		end
	end
end
