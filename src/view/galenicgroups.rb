#!/usr/bin/env ruby
#GalenicGroupsView -- oddb -- 25.03.2003 -- andy@jetnet.ch

require 'view/privatetemplate'
require 'view/descriptionlist'
require 'view/pointervalue'

module ODDB
	class GalenicGroups < DescriptionList
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
			:description	=>	PointerLink,
			:oid					=>	PointerLink,
		}
	end
	class GalenicGroupsView < PrivateTemplate
		CONTENT = GalenicGroups
		SNAPBACK_EVENT = :galenic_groups
	end
end
