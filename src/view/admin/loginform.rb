#!/usr/bin/env ruby
# View::Admin::LoginForm -- oddb -- 25.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/form'
require 'htmlgrid/pass'

module ODDB
	module View
		module Admin
class LoginForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0]   =>  :email,
		[0,1]   =>  :pass,
		[1,2]   =>  :submit,
	}
	CSS_MAP = {
		[0,0,2,3]	=>	'list',
	}
	CSS_CLASS = 'component'
	EVENT = :login
	LABELS = true
	SYMBOL_MAP = {
		:pass	=>	HtmlGrid::Pass,
	}
	LEGACY_INTERFACE = false
	def email(model)
		input = HtmlGrid::InputText.new(:email, model, @session, self)
		input.css_id = 'email'
		self.onload = "document.getElementById('email').focus();"
		input
	end
end
		end
	end
end
