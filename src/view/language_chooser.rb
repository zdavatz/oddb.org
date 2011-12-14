#!/usr/bin/env ruby
# encoding: utf-8
# LanguageChooser -- oddb -- hwyss@ywesee.com

require 'view/navigation'

module ODDB
	module View
module UserSettings
	def language_chooser(model, session)
		if(@lookandfeel.enabled?(:language_switcher))
			LanguageChooser.new(@lookandfeel.languages, session, self)
		end
	end
	def language_chooser_short(model, session)
		if(@lookandfeel.enabled?(:language_switcher))
			LanguageChooserShort.new(@lookandfeel.languages, session, self)
		end
	end
end
class LanguageChooser < Navigation
	CSS_CLASS = nil #"center"
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
class LanguageChooserShort < Navigation
  CSS_CLASS = nil
  NAV_METHOD = :languages
  NAV_LINK_CLASS = LanguageNavigationLink
  HTML_ATTRIBUTES = { }
  def build_navigation
    offset = 0
    @lookandfeel.languages.each_with_index do |state, idx| 
      xpos = idx*2
      pos = [xpos,0]
      if(state.is_a?(String))
        state = state.intern
      end
      symbol_map.store(state, LanguageNavigationLinkShort)
      components.store(pos, state)
      components.store([xpos-1,0], :navigation_divider) if idx > 0
      offset = idx.next * 2
    end
  end
end
	end
end
