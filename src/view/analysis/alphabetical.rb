#!/usr/bin/env ruby
# encoding: utf-8
# View::Analysis::Alphabetical -- oddb.org -- 05.07.2006 -- sfrischknecht@ywesee.com

require 'view/analysis/result'
require 'view/alphaheader'

module ODDB
	module View
		module Analysis
class AlphabeticalList < View::Analysis::List
	include AlphaHeader
	SORT_DEFAULT = :description
end
class AlphabeticalComposite < HtmlGrid::Composite
	include ResultFootBuilder
	EXPLAIN_RESULT = View::Analysis::ExplainResult
	CSS_CLASS = 'composite'
	COMPONENTS	=	{
		[0,0]		=>	AlphabeticalList,
		[0,1]		=>	:result_foot,
	}
end
class Alphabetical < View::PrivateTemplate
	CONTENT = View::Analysis::AlphabeticalComposite
end
		end
	end
end
