#!/usr/bin/env ruby
# SubstanceResultListView -- oddb -- 23.08.2004 -- maege@ywesee.com

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
	class SubstanceResultList < FormList
		COMPONENTS = {
			[0,0]	=>	:name,
			[1,0]	=>	:en,
			[2,0]	=>	:lt,
			[3,0]	=>	:de,
			[4,0]	=>	:fr,
		}
		DEFAULT_CLASS = HtmlGrid::Value
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'list',
			[1,0]	=>	'list',
			[2,0]	=>	'list',
			[3,0]	=>	'list',
			[4,0]	=>	'list',
		}
		CSS_HEAD_MAP = {
			[0,0] =>	'th',
			[1,0] =>	'th',
			[2,0] =>	'th',
			[3,0] =>	'th',
			[4,0] =>	'th',
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
		def name(model, session)
			link = PointerLink.new(:name, model, session, self)
			link
		end
		EVENT = :new_substance
		#include AlphaHeader
	end
end
