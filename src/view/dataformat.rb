#!/usr/bin/env ruby
# View::DataFormat -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'plugin/fxcrossrate'

module ODDB
	module View
		module DataFormat
			def most_precise_dose(model, session)
				if(model.respond_to?(:most_precise_dose))
					dose = model.most_precise_dose
					(dose && (dose.qty > 0)) ? dose : nil
				end
			end
			def price_exfactory(model, session)
				formatted_price(:price_exfactory, model)
			end
			def price_public(model, session)
				formatted_price(:price_public, model)
			end
			private
			def formatted_price(key, model)
				price_chf = model.send(key).to_i
				if(price_chf != 0)
					prices = {
						'CHF'	=>	price_chf,
						'EUR'	=>	convert_price(price_chf, 'EUR'),
						'USD'	=>	convert_price(price_chf, 'USD'),
					}
					prices.dup.each { |cur, val|
						prices.store(cur, @lookandfeel.format_price(val))
					}
					display = prices.delete(@session.currency)
					span = HtmlGrid::Span.new(model, @session, self)
					price = HtmlGrid::NamedComponent.new(key, model, @session, self)
					price.value = display
					span.value = price
					span.label = true
					title = prices.sort.collect { |pair| pair.join(': ') }.join(' / ')
					span.set_attribute('title', title)
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
			def convert_price(price, currency)
				if(rate = @session.get_currency_rate(currency))
					price * rate
				end
			end
		end
	end
end
