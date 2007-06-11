#!/usr/bin/env ruby
# View::Substances::Substances -- oddb -- 25.05.2004 -- mhuggler@ywesee.com

require 'htmlgrid/value'
require 'htmlgrid/link'
#require 'htmlgrid/urllink'
require 'htmlgrid/list'
require 'util/umlautsort'
require 'view/pointervalue'
require 'view/descriptionvalue'
require 'view/form'
require 'view/resultcolors'
require 'view/resulttemplate'
require 'view/alphaheader'

module ODDB
	module View
		module Substances
class List < View::FormList
	COMPONENTS = {
		[0,0]	=>	:name,
    [1,0] =>  :effective_form,
    [0,1] =>  "&nbsp;",
    [1,1] =>  "&nbsp;",
		[2,0]	=>	:de,
		[3,0]	=>	:fr,
		[2,1]	=>	:en,
		[3,1]	=>	:lt,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,4,2]	=>	'list',
	}
	CSS_HEAD_MAP = {
		[0,0,4,2] =>	'th',
	}
	LOOKANDFEEL_MAP = {
		:name	=>	:default_name,
		:en		=>	:en_description,
		:lt		=>	:lt_description,
		:de		=>	:de_description,
		:fr		=>	:fr_description,
	}
  OFFSET_STEP = [0,2]
	SORT_DEFAULT = :name
	SORT_REVERSE = false
	def name(model, session)
		link = View::PointerLink.new(:name, model, session, self)
		link
	end
	EVENT = :new_substance
	include AlphaHeader
end
class ListForm < View::Form
	COLSPAN_MAP = {
		[0,1]	=>	2,
	}
	COMPONENTS = {
		[1,0]		=>	:search_query,
		[1,0,1]	=>	:submit,
		[0,1]		=>	View::Substances::List,
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query	=>	View::SearchBar,
	}
	CSS_MAP = {
		[1,0]	=>	'search',	
	}
end
class Substances < View::ResultTemplate
	CONTENT = View::Substances::ListForm
end
		end
	end
end
