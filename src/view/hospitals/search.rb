#!/usr/bin/env ruby
# View::Hospitals::Init -- oddb -- 15.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'view/publictemplate'
require 'view/hospitals/welcomehead'
require 'view/hospitals/centeredsearchform'

module ODDB
	module View
		module Hospitals
class Search < View::PublicTemplate
	CONTENT = View::Hospitals::GoogleAdSenseComposite
	CSS_CLASS = 'composite'
	HEAD = View::Hospitals::WelcomeHeadHospitals
end
		end
	end
end
