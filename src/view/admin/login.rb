#!/usr/bin/env ruby
# encoding: utf-8
# View::Login -- oddb -- hwyss@ywesee.com

require 'view/publictemplate'
require 'view/logohead'
require 'view/admin/logincomposite'

module ODDB
	module View
		module Admin
class Login < View::PublicTemplate
	CONTENT = View::Admin::LoginComposite
	HEAD = View::LogoHead
end
		end
	end
end
