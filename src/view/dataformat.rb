#!/usr/bin/env ruby
# View::DataFormat -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'plugin/fxcrossrate'
require 'view/external_links'

module ODDB
	module View
		module DataFormat
			include ExternalLinks
			def breakline(txt, length)
				name = ''
				line = ''
				last = ''
				txt.to_s.split(/(:?[\s-])/).each { |part|
					if((line.length + last.length + part.length) > length \
						&& part.length > 3)
						name << line << last << '<br>'
						line = ''
					else
						line << last
					end
					last = part
				}
				name << line << last
			end
			def most_precise_dose(model, session=@session)
				if(model.respond_to?(:most_precise_dose))
					dose = model.most_precise_dose
					dose = (dose && (dose.qty > 0)) ? dose : nil
					dose.to_s.gsub(/\s+/, '&nbsp;')
				end
			end
			def name_base(model, session=@session)
				link = HtmlGrid::Link.new(:compare, model, session, self)
				link.href = @lookandfeel._event_url(:compare, {'pointer'=>model.pointer})
				link.value = breakline(model.name_base, 25)
				link.set_attribute('class', 
					'result-big' << resolve_suffix(model))
				query = @session.persistent_user_input(:search_query)
				if(model.good_result?(query))
					 link.set_attribute('name', 'best_result')
				end
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
				item = if(price_chf != 0)
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
					title = prices.sort.collect { |pair| pair.join(': ') }.join(' / ')
					span.set_attribute('title', title)
					span
				else
					wiki_link(model, :price_request, :price_request_pagename)
				end
				item.label = true
				item	
			end
			def convert_price(price, currency)
				if(rate = @session.get_currency_rate(currency))
					price * rate
				end
			end
		end
	end
end
