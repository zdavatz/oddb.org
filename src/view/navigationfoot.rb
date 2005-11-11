#!/usr/bin/env ruby
# View::NavigationFoot -- oddb -- 19.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'view/navigation'
require 'view/copyright'

module ODDB
	module View
		class NavigationFoot < HtmlGrid::Composite
			CSS_CLASS = "navigation-foot"
			COMPONENTS = {
				[0,0]		=>	:copyright,
				[1,0]		=>	View::Navigation, #:navigation,
			}
			HTML_ATTRIBUTES = {
				'valign'	=>	'bottom',
			}
			CSS_MAP = {
				[0,0,2]	=>	'navigation'
			}
			LEGACY_INTERFACE = false
			def copyright(model)
				if(@lookandfeel.enabled?(:just_medical_structure, false))
					View::JustMedicalCopyright.new(model, @session, self)
				else
					View::Copyright.new(model, @session, self)
				end
			end
			def navigation(model)
				if(@lookandfeel.enabled?(:just_medical_structure, false))
					View::JustMedicalNavigation.new(model, @session, self)
				else
					View::Navigation.new(model, @session, self)
				end
			end
		end
	end
end
