#!/usr/bin/env ruby
# View::User::PayPalRedirect -- ODDB -- 20.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/component'

module ODDB
	module View
		module User
class PayPalRedirect < HtmlGrid::Component
	def http_headers 
		invoice = @model.oid
		ret_url = @lookandfeel._event_url(:paypal, {:invoice => invoice})
		url = 'https://' << PAYPAL_SERVER << '/cgi-bin/webscr?' \
			<< "business=#{PAYPAL_RECEIVER}&" \
			<< "item_name=Datendownload&item_number=#{invoice}&" \
			<< "invoice=#{invoice}&" \
			<< "amount=#{sprintf('%3.2f', model.total_brutto)}&" \
			<< 'no_shipping=1&no_note=1&currency_code=EUR&' \
			<< "return=#{ret_url}&" \
			<< "cancel_return=#{@lookandfeel.base_url}&" \
			<< "image_url=https://www.generika.cc/images/oddb_paypal.jpg"
		if(user = @session.resolve(@model.user_pointer))
			url << "&email=#{user.email}&first_name=#{user.name_first}" \
				<< "&last_name=#{user.name}&address1=#{user.address}" \
				<< "&city=#{user.location}&zip=#{user.plz}" \
				<< "&redirect_cmd=_xclick&cmd=_ext-enter"
		else
			url << '&cmd=_xclick'
		end
		{
			'Location'	=>	url,
		}
	end
end
		end
	end
end
