#!/usr/bin/env ruby
# View::Drugs::Indication -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'
require 'view/descriptionform'

module ODDB
	module View
		module Drugs
class IndicationForm < View::DescriptionForm
	DESCRIPTION_CSS = 'xl'
end
class IndicationComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'indication',
		[0,1]	=>	View::Drugs::IndicationForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
end
class Indication < View::PrivateTemplate
	CONTENT = View::Drugs::IndicationComposite
	SNAPBACK_EVENT = :indications
end
		end
	end
end
