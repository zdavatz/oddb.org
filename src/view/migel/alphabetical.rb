#!/usr/bin/env ruby
# encoding: utf-8
# View::Migel::Alphabetical -- oddb -- 02.02.2006 -- hwyss@ywesee.com

require 'view/migel/result'
require 'view/alphaheader'

module ODDB
	module View
		module Migel
class AlphabeticalList < View::Migel::List
	include AlphaHeader
end
class AlphabeticalComposite < HtmlGrid::Composite
	include ResultFootBuilder
	EXPLAIN_RESULT = View::Migel::ExplainResult
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	AlphabeticalList,
		[0,1]	=>	:result_foot,
	}
end
class Alphabetical < View::PrivateTemplate
	CONTENT = View::Migel::AlphabeticalComposite
end
		end
	end
end
