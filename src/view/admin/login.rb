#!/usr/bin/env ruby
# View::Login -- oddb -- hwyss@ywesee.com

require 'view/publictemplate'
require 'view/logohead'
require 'view/admin/logincomposite'

module ODDB
	module View
		module Admin
class Login < PublicTemplate
	CONTENT = View::Admin::LoginComposite
	HEAD = View::LogoHead
end
		end
	end
end
