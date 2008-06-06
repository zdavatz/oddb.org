#!/usr/bin/env ruby
# View::Admin::LoginForm -- oddb -- 25.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/form'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/pass'
require 'view/htmlgrid/composite'

module ODDB
	module View
		module Admin
class LoginForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0]   =>  :email,
		[0,1]   =>  :pass,
		[1,2,0] =>  :remember_me,
    [1,2,1] =>  'remember_me',
		[1,3]   =>  :submit,
		[1,4]	=>	:password_lost,
	}
	CSS_MAP = {
		[0,0,2,5]	=>	'list',
	}
	CSS_CLASS = 'component'
	EVENT = :login
	LABELS = true
	SYMBOL_MAP = {
		:pass	       =>	HtmlGrid::Pass,
	}
	LEGACY_INTERFACE = false
	event_link :password_lost
	def email(model)
		input = HtmlGrid::InputText.new(:email, model, @session, self)
		input.css_id = 'email'
		self.onload = "document.getElementById('email').focus();"
		input
	end
  def remember_me(model)
    box = HtmlGrid::InputCheckbox.new(:remember_me, model, @session, self)
    box.set_attribute 'checked', @session.cookie_set_or_get(:remember_me)
    box.label = false
    box
  end
end
		end
	end
end
