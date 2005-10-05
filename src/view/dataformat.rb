#!/usr/bin/env ruby
# View::DataFormat -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'plugin/fxcrossrate'

module ODDB
	module View
		module DataFormat
			def breakline(txt, length)
				name = ''
				line = ''
				txt.to_s.split(/(:?[\s-])/).each { |part|
					if((line.length + part.length) > length)
						name << line << '<br>'
						line = part
					else
						line << part
					end
				}
				name << line
			end
			def most_precise_dose(model, session=@session)
				if(model.respond_to?(:most_precise_dose))
					dose = model.most_precise_dose
					(dose && (dose.qty > 0)) ? dose : nil
				end
			end
			def name_base(model, session=@session)
				link = HtmlGrid::Link.new(:compare, model, session, self)
				link.href = @lookandfeel._event_url(:compare, {'pointer'=>model.pointer})
				link.value = breakline(model.name_base, 25)
				link.set_attribute('class', 
					'result-big' << resolve_suffix(model))
				indication = model.registration.indication
				descr = model.descr
				if(descr && descr.empty?)
					descr = nil
				end
				title = [
					descr,
					@lookandfeel.lookup(:ean_code, model.barcode),
					(indication.send(@session.language) unless(indication.nil?)),
				].compact.join(', ')
				link.set_attribute('title', title)
				link
			end
			def price(model, session=@session)
				formatted_price(:price, model)
			end
			def price_exfactory(model, session=@session)
				formatted_price(:price_exfactory, model)
			end
			def price_public(model, session=@session)
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
