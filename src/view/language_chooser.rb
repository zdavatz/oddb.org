#!/usr/bin/env ruby
# LanguageChooser -- oddb -- hwyss@ywesee.com

require 'view/navigation'

module ODDB
	module View
module UserSettings
	def language_chooser(model, session)
		LanguageChooser.new(@lookandfeel.languages, session, self)
	end
end
class LanguageChooser < Navigation
	CSS_CLASS = "ccomponent"
	NAV_METHOD = :languages
	NAV_LINK_CLASS = LanguageNavigationLink
	HTML_ATTRIBUTES = { }
	def build_navigation
		offset = 0
		@lookandfeel.languages.each_with_index { |state, idx| 
			xpos = idx*2
			pos = [xpos,0]
			if(state.is_a?(String))
				state = state.intern
			end
			symbol_map.store(state, LanguageNavigationLink)
			components.store(pos, state)
			components.store([xpos-1,0], :navigation_divider) if idx > 0
			offset = idx.next * 2
		}
		if(@lookandfeel.enabled?(:currency_switcher))
			components.store([offset-1, 0], 'dash_separator')
			@lookandfeel.currencies.each_with_index { |state, idx| 
				xpos = offset + idx*2
				pos = [xpos,0]
				if(state.is_a?(String))
					state = state.intern
				end
				symbol_map.store(state, CurrencyNavigationLink)
				components.store(pos, state)
				components.store([xpos-1,0], :navigation_divider) if idx > 0
			}
		end
	end
end
	end
end
