#!/usr/bin/env ruby
# encoding: utf-8
# View::User::PayPalThanks -- oddb -- 10.09.2003 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/composite'

module ODDB
	module View
		module User
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
class PayPalThanks < View::PublicTemplate
	CONTENT = View::User::PayPalThanksComposite
end
		end
	end
end
