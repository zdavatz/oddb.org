#!/usr/bin/env ruby
# View::Admin::AtcClass -- oddb -- 18.07.2003 -- hwyss@ywesee.com 

require 'view/drugs/privatetemplate'
require 'view/descriptionform'

module ODDB
	module View
		module Admin
class AtcClassForm < View::DescriptionForm
	DELETE_BUTTON = false
end
class AtcClassComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'atc_class',
		[0,1]	=>	View::Admin::AtcClassForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
end
class AtcClass < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::AtcClassComposite
	SNAPBACK_EVENT = :atc_chooser
end
		end
	end
end
