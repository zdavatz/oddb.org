#!/usr/bin/env ruby
# encoding: utf-8
# View::ResultTemplate -- oddb -- 20.10.2004 -- jlang@ywesee.com

require 'view/publictemplate'
require 'view/navigation'
require 'view/welcomehead'
require 'view/logohead'

module ODDB
	module View
		class ResultTemplate < PublicTemplate
			HEAD = View::WelcomeHead
			COMPONENTS = {}
			def init
				@components = {
					[0,0]		=>	:head,
					[0,1]		=>	:content,
					[0,2]		=>	:foot,
				}
				super
			end
		end
	end
end
