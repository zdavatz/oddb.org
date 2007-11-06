#!/usr/bin/env ruby
# View::Admin::GalenicGroups -- oddb -- 25.03.2003 -- andy@jetnet.ch

require 'view/drugs/privatetemplate'
require 'view/descriptionlist'
require 'view/pointervalue'

module ODDB
	module View
		module Admin
class GalenicGroupsList < View::DescriptionList
	COMPONENTS = {
		[0,0]	=>	:oid,
		[1,0]	=>	:description,
		[2,0]	=>	:de,
		[3,0]	=>	:en,
		[4,0]	=>	:fr,
	}
	CSS_MAP = {
		[0,0,5]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'th'
	EVENT = :new_galenic_group
	SYMBOL_MAP = {
		:description	=>	View::PointerLink,
		:oid					=>	View::PointerLink,
	}
end
class GalenicGroups < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::GalenicGroupsList
	SNAPBACK_EVENT = :galenic_groups
end
		end
	end
end
