#!/usr/bin/env ruby
# View::Substances::ResultList -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'htmlgrid/value'
require 'htmlgrid/link'
#require 'htmlgrid/urllink'
require 'htmlgrid/list'
require 'util/umlautsort'
require 'view/pointervalue'
require 'view/descriptionvalue'
require 'view/form'
require 'view/resultcolors'
require 'view/publictemplate'
require 'view/alphaheader'

module ODDB
	module View
		module Substances
class ResultList < View::FormList
	COMPONENTS = {
		[0,0]	=>	:name,
		[1,0]	=>	:de,
		[2,0]	=>	:fr,
		[3,0]	=>	:en,
		[4,0]	=>	:lt,
		[5,0]	=>	:effective_form,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,6]	=>	'list',
	}
	CSS_HEAD_MAP = {
		[0,0,6] =>	'th',
	}
	LOOKANDFEEL_MAP = {
		:name	=>	:default_name,
		:en		=>	:en_description,
		:lt		=>	:lt_description,
		:de		=>	:de_description,
		:fr		=>	:fr_description,
	}
	SORT_DEFAULT = :name
	SORT_REVERSE = false
	SORT_HEADER = false
	def name(model, session)
		link = View::PointerLink.new(:name, model, session, self)
		link
	end
	EVENT = :new_substance
	#include AlphaHeader
end
		end
	end
end
