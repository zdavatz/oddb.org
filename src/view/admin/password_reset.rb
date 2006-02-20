#!/usr/bin/env ruby
# View::Admin::PasswordReset -- oddb -- 20.02.2006 -- hwyss@ywesee.com

require 'view/publictemplate'
require 'view/setpass'

module ODDB
	module View
		module Admin
class PasswordResetForm < SetPassForm
	DEFAULT_CLASS = HtmlGrid::Value
	EVENT = :password_reset
end
class PasswordResetComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=> 'password_reset',
		[0,1]	=> PasswordResetForm,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
	}
end
class PasswordReset < PublicTemplate
	CONTENT = PasswordResetComposite
end
		end
	end
end
