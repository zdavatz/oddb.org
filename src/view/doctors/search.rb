#!/usr/bin/env ruby
# View::Doctors::Init -- oddb -- 17.09.2004 -- jlang@ywesee.com

require 'view/publictemplate'
require 'view/welcomehead'
require 'view/doctors/centeredsearchform'

module ODDB
	module View
		module Doctors
class Search < View::PublicTemplate
	CONTENT = View::Doctors::GoogleAdSenseComposite
	CSS_CLASS = 'composite'
	HEAD = View::WelcomeHead
end
		end
	end
end
