#!/usr/bin/env ruby
# LanguageChooser -- oddb -- hwyss@ywesee.com

require 'view/navigation'

module ODDB
	module View
module LanguageChooserFactory
	def language_chooser(model, session)
		LanguageChooser.new(@lookandfeel.languages, session, self)
	end
end
class LanguageChooser < Navigation
	CSS_CLASS = "ccomponent"
	NAV_METHOD = :languages
	NAV_LINK_CLASS = LanguageNavigationLink
	HTML_ATTRIBUTES = { }
end
	end
end
