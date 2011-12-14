#!/usr/bin/env ruby
# encoding: utf-8
# View::Interactions::Search -- oddb -- 26.05.2004 -- mhuggler@ywesee.com

require 'view/interactions/centeredsearchform'

module ODDB
	module View
		module Interactions
class Search < View::Search
	CONTENT = View::Interactions::GoogleAdSenseComposite
end
		end
	end
end
