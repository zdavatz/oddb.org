#!/usr/bin/env ruby
# AtcClassView -- oddb -- 18.07.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'
require 'view/descriptionform'

module ODDB
	class AtcClassForm < DescriptionForm
		DELETE_BUTTON = false
	end
	class AtcClassComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	'atc_class',
			[0,1]	=>	AtcClassForm,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th',
		}
	end
	class AtcClassView < PrivateTemplate
		CONTENT = AtcClassComposite
		SNAPBACK_EVENT = :atc_chooser
		def snapback
			[super, [@session.persistent_user_input(:code)]]
		end
	end
end
