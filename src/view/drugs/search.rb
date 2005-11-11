#!/usr/bin/env ruby
# View::Drugs::Search -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'view/publictemplate'
require 'view/drugs/centeredsearchform'
require 'view/welcomehead'

module ODDB
	module View
		module Drugs
class Search < View::PublicTemplate
	CONTENT = View::Drugs::GoogleAdSenseComposite
	CSS_CLASS = 'composite'
	HEAD = View::WelcomeHead
	def head(model, session=@session)
		if(@lookandfeel.enabled?(:just_medical_structure, false))
			just_medical(model)
		else
			super
		end
	end
end
		end
	end
end
