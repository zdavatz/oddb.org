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
class GalenicGroups < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::GalenicGroupsList
	SNAPBACK_EVENT = :galenic_groups
end
		end
	end
end
