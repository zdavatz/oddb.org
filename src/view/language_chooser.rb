#!/usr/bin/env ruby
# LanguageChooser -- oddb -- hwyss@ywesee.com

require 'view/navigation'

module ODDB
	module View
class LanguageChooser < Navigation
	CSS_CLASS = "ccomponent"
	NAV_METHOD = :languages
	NAV_LINK_CLASS = LanguageNavigationLink
end
	end
end
