#!/usr/bin/env ruby
# PayPalThanksView -- oddb -- 10.09.2003 -- maege@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/composite'

module ODDB
	class PayPalThanksComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	'thanks_for_donation_title',
			[0,1]	=>	'thanks_for_donation_txt',
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th',
			[0,1,1,1]	=>	'list',
		}
	end
	class PayPalThanksView < PublicTemplate
		CONTENT = PayPalThanksComposite
	end
end
