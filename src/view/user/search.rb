#!/usr/bin/env ruby
# View::User::Search -- oddb -- 06.09.2004 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/welcomehead'
require 'view/user/centeredsearchform'

module ODDB
	module View
		module User
class Search < View::PublicTemplate
	CONTENT = View::User::GoogleAdSenseComposite
	CSS_CLASS = 'composite'
	HEAD = View::WelcomeHead
end
		end
	end
end
