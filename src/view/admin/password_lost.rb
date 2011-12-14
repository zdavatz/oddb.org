#!/usr/bin/env ruby
# encoding: utf-8
# View::Admin::PasswordLost -- oddb -- 17.02.2006 -- hwyss@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/errormessage'

module ODDB
	module View
		module Admin
class PasswordLostForm < Form
	LABELS = true
	EVENT = :password_request
	COMPONENTS = {
		[0,0]	=>	:email,
		[1,1]	=>	:submit,
	}
	CSS_MAP = {
		[0,0,2,2]	=>	'list',
	}
end
class PasswordLostComposite < HtmlGrid::Composite
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	'password_lost',
		[0,1]	=>	'explain_password_lost',
		[0,2]	=>	PasswordLostForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'list',
	}
	def init
		super
		error_message(2)
	end
end
class PasswordLost < PublicTemplate
	CONTENT = PasswordLostComposite
end
		end
	end
end
