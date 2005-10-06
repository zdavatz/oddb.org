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
end
class Checkout < PublicTemplate
	CONTENT = CheckoutComposite
end
		end
	end
end
