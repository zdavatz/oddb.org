#!/usr/bin/env ruby
# IndicationView -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'
require 'view/descriptionform'

module ODDB
	class IndicationForm < DescriptionForm
		DESCRIPTION_CSS = 'xl'
	end
	class IndicationComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	'indication',
			[0,1]	=>	IndicationForm,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th',
		}
	end
	class IndicationView < PrivateTemplate
		CONTENT = IndicationComposite
		SNAPBACK_EVENT = :indications
	end
end
