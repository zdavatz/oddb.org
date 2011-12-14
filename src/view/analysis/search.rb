#!/usr/bin/env ruby
# encoding: utf-8
# View::Analysis::Search -- oddb.org -- 13.06.2006 -- sfrischknecht@ywesee.com

require 'view/publictemplate'
require 'view/custom/head'
require 'view/analysis/centeredsearchform'

module ODDB
	module View
		module Analysis
class Search < View::PublicTemplate
	include View::Custom::Head
	HEAD = View::WelcomeHead
	CONTENT = View::Analysis::GoogleAdSenseComposite
	CSS_CLASS = 'composite'
end
		end
	end
end
