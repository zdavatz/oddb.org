#!/usr/bin/env ruby
# encoding: utf-8
# View::HC_providers::Init -- oddb -- 15.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'view/publictemplate'
require 'view/hc_providers/welcomehead'
require 'view/hc_providers/centeredsearchform'

module ODDB
	module View
		module HC_providers
class Search < View::PublicTemplate
	CONTENT = View::HC_providers::GoogleAdSenseComposite
	CSS_CLASS = 'composite'
	HEAD = View::HC_providers::WelcomeHeadHC_providers
end
		end
	end
end
