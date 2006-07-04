#!/usr/bin/env ruby
# View::User::GenericDefinition -- oddb -- 05.01.2004 -- mhuggler@ywesee.com

require 'htmlgrid/composite'
require 'view/popuptemplate'

module ODDB
	module View
		module User
class GenericDefinitionInfo < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'generic_definition_title',
		[0,1] =>	'generic_definition_text1',
		[0,2] =>	'generic_definition_text2',
		[0,3] =>	'generic_definition_text3',
		[0,4] =>	'generic_definition_text4',
		[0,5] =>	'generic_definition_text5',
		[0,6]	=>	'conclusion',
		[0,7] =>	'generic_definition_text6',
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'list',
		[0,2]	=>	'list',
		[0,3]	=>	'list',
		[0,4]	=>	'list',
		[0,5]	=>	'list',
		[0,6]	=>	'list title',
		[0,7]	=>	'list',
	}
end
class GenericDefinition < View::PopupTemplate
	HEAD = View::PopupLogoHead
	CONTENT = View::User::GenericDefinitionInfo
end
		end
	end
end
