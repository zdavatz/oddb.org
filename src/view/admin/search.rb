#!/usr/bin/env ruby
# View::Admin::Search -- oddb -- 07.09.2004 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/admin/centeredsearchform'
require 'view/welcomehead'

module ODDB
	module View
		module Admin
class Search < View::PublicTemplate
	CONTENT = View::Admin::CenteredSearchComposite
	CSS_CLASS = 'composite'
	HEAD = View::WelcomeHead
end
		end
	end
end
