#!/usr/bin/env ruby
# View::Admin::LoginComposite -- oddb -- 26.11.2002 -- hwyss@ywesee.com 

require 'view/admin/loginform'
require 'htmlgrid/text'

module ODDB
	module View
		module Admin
class LoginComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	"login_welcome",
		[0,1]	=>	View::Admin::LoginForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
end
		end
	end
end
