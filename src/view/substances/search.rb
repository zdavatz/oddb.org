#!/usr/bin/env ruby
# encoding: utf-8
# View::Substances::Search -- oddb -- 23.08.2004 -- mhuggler@ywesee.com

require 'view/substances/centeredsearchform'

module ODDB
	module View
		module Substances
class Search < View::Search
	CONTENT = View::Substances::CenteredSearchComposite
end
		end
	end
end
