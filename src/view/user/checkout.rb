#!/usr/bin/env ruby
# View::User::Checkout -- ODDB -- 18.04.2005 -- hwyss@ywesee.com

require 'view/publictemplate'

module ODDB
	module View
		module User
class CheckoutComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,1]	=>	:paypal,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	LEGACY_INTERFACE = false
	def paypal(model)
		link = HtmlGrid::Link.new(:paypal, model, @session, self)
		link.value = 'Bezahlen via PayPal'
		url = 'cmd=_xclick&business=bastel@schlumpf.sh&'
		url << "item_name=Datendownload&item_number=#{model.oid}&"
		url << "amount=#{sprintf('%3.2f', model.total)}&"
		url << 'no_shipping=1&no_note=1&currency_code=EUR'
		url = CGI.escape(url)
		link.href = 'https://www.sandbox.paypal.com/cgi-bin/webscr?' << url
		link
	end
end
class Checkout < PublicTemplate
	CONTENT = CheckoutComposite
end
		end
	end
end
