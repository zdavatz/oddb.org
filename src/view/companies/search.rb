#!/usr/bin/env ruby
# encoding: utf-8
# View::Companies::Init -- oddb -- 06.09.2004 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/welcomehead'
require 'view/companies/centeredsearchform'

module ODDB
	module View
		module Companies
class Search < View::PublicTemplate
	CONTENT = View::Companies::GoogleAdSenseComposite
	CSS_CLASS = 'composite'
	HEAD = View::WelcomeHead
end
		end
	end
end
