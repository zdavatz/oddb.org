#!/usr/bin/env ruby
# encoding: utf-8
# View::PayPal::Redirect -- ODDB -- 20.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/component'

module ODDB
	module View
		module PayPal
class Redirect < HtmlGrid::Component
	def http_headers 
		invoice = @model.oid
		names = @model.items.values.collect { |item| 
      txt = item.text
      case txt
      when 'unlimited access'
        'Unlimited Access to ch.oddb.org for %i days' % item.quantity
      else
        txt
      end
    }.join(' ,')
		ret_url = @lookandfeel._event_url(:paypal_return, 
			{:invoice => invoice})
		url = 'https://' << PAYPAL_SERVER << '/cgi-bin/webscr?' \
			<< "business=#{PAYPAL_RECEIVER}&" \
			<< "item_name=#{names}&item_number=#{invoice}&" \
			<< "invoice=#{invoice}&custom=ch.oddb.org&" \
			<< "amount=#{sprintf('%3.2f', model.total_brutto)}&" \
			<< 'no_shipping=1&no_note=1&currency_code=EUR&' \
			<< "return=#{ret_url}&" \
			<< "cancel_return=#{@lookandfeel.base_url}&" \
			<< "image_url=https://www.generika.cc/images/oddb_paypal.jpg"
		if((user = @session.user).is_a?(YusUser))
			url << "&email=#{user.email}&first_name=#{user.name_first}" \
				<< "&last_name=#{user.name_last}&address1=#{user.address}" \
				<< "&city=#{user.city}&zip=#{user.plz}" \
				<< "&redirect_cmd=_xclick&cmd=_ext-enter"
		else
			url << '&cmd=_xclick'
		end
		{
			'Location'	=>	url,
		}
	end
  def to_html(context)
    ''
  end
end
		end
	end
end
