#!/usr/bin/env ruby
# LoginComposite -- oddb -- 26.11.2002 -- hwyss@ywesee.com 

require 'view/loginform'
require 'htmlgrid/text'

module ODDB
	class LoginComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	"login_welcome",
			[0,1]	=>	LoginForm,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th',
		}
	end
end
