#!/usr/bin/env ruby
# IndicationsView -- oddb -- 03.07.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'
require 'view/descriptionlist'
require 'view/pointervalue'
require 'view/pointervalue'
require 'view/alphaheader'

module ODDB
	class IndicationList < DescriptionList
		CSS_MAP = {
			[0,0]	=>	'list',
		}
		DEFAULT_HEAD_CLASS = nil
		EVENT = :new_indication
		SYMBOL_MAP = {
			:description	=>	PointerLink,
		}
		include AlphaHeader
	end
	class IndicationsView < PrivateTemplate
		CONTENT = IndicationList
		SNAPBACK_EVENT = :indications
	end
end
