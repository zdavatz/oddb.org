#!/usr/bin/env ruby
# View::AuthInfo -- oddb -- 22.12.2004 -- hwyss@ywesee.com

require 'view/publictemplate'

module ODDB
	module View
		module User
class AuthInfoComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	"register_download",
		[0,1]	=>	:auth_info,
		[0,2]	=>	:back,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1,1,2]	=>	'list',
	}
	LEGACY_INTERFACE = false
	def auth_info(model)
		@lookandfeel.lookup(:auth_info, model.email)
	end
	def back(model)
		link = HtmlGrid::Link.new(:auth_back, model, @session, self)
		link.href = @lookandfeel._event_url(:download_export)
		link
	end
end
class AuthInfo < View::PublicTemplate
	CONTENT = View::User::AuthInfoComposite
end
		end
	end
end
