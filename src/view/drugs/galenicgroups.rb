#!/usr/bin/env ruby
# View::Drugs::GalenicGroups -- oddb -- 25.03.2003 -- andy@jetnet.ch

require 'view/privatetemplate'
require 'view/descriptionlist'
require 'view/pointervalue'

module ODDB
	module View
		module Drugs
class GalenicGroupsList < View::DescriptionList
	COMPONENTS = {
		[0,0]	=>	:oid,
		[1,0]	=>	:description,
	}
	CSS_MAP = {
		[0,0,2]	=>	'list',
	}
	DEFAULT_HEAD_CLASS = 'th'
	EVENT = :new_galenic_group
	SYMBOL_MAP = {
		:description	=>	View::PointerLink,
		:oid					=>	View::PointerLink,
	}
end
class GalenicGroups < View::PrivateTemplate
	CONTENT = View::Drugs::GalenicGroupsList
	SNAPBACK_EVENT = :galenic_groups
end
		end
	end
end
