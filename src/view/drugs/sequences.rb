#!/usr/bin/env ruby
# View::Drugs::Sequences -- oddb -- 08.02.2005 -- hwyss@ywesee.com

require 'view/publictemplate'
require 'view/resultcolors'

module ODDB
	module View
		module Drugs
class SequenceList < HtmlGrid::List
	include View::ResultColors
	COMPONENTS = {
		[0,0]	=>	:iksnr,
		[1,0]	=>	:name,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'small result-edit',
		[1,0]	=>	'result-big',
	}
	SORT_DEFAULT = :name
	SORT_REVERSE = false
	SORT_HEADER = false
	include AlphaHeader
	def iksnr(model, session)
		View::PointerLink.new(:iksnr, model, session, self)
	end
end
class Sequences < View::PublicTemplate
	CONTENT = View::Drugs::SequenceList
end
		end
	end
end
