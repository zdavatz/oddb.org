#!/usr/bin/env ruby
# View::Drugs::Indications -- oddb -- 03.07.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'
require 'view/descriptionlist'
require 'view/pointervalue'
require 'view/pointervalue'
require 'view/alphaheader'

module ODDB
	module View
		module Drugs
class IndicationList < View::DescriptionList
	CSS_MAP = {
		[0,0]	=>	'list',
	}
	DEFAULT_HEAD_CLASS = nil
	EVENT = :new_indication
	SYMBOL_MAP = {
		:description	=>	View::PointerLink,
	}
	include View::AlphaHeader
end
class Indications < View::PrivateTemplate
	CONTENT = View::Drugs::IndicationList
	SNAPBACK_EVENT = :indications
end
		end
	end
end
