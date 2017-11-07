#!/usr/bin/env ruby
# encoding: utf-8
# View::ResultTemplate -- oddb -- 20.10.2004 -- jlang@ywesee.com

require 'view/publictemplate'
require 'view/navigation'
require 'view/sponsorhead'

module ODDB
	module View
		class ResultTemplate < PublicTemplate
			HEAD = View::LogoHead
			COMPONENTS = {}
			def init
				@components = {
					[0,0]		=>	:content,
					[0,1]		=>	:foot,
				}
				super
			end
		end
	end
end
