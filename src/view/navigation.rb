#!/usr/bin/env ruby
# View::Navigation -- oddb -- 21.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/link'
require 'htmlgrid/popuplink'
require 'view/navigationlink'
require 'view/external_links'

module ODDB
	module View
		class Navigation < HtmlGrid::Composite
			COMPONENTS = {}
			LEGACY_INTERFACE = false
			NAV_LINK_CLASS = NavigationLink
			NAV_LINK_CSS = 'subheading'
			NAV_METHOD = :navigation
			HTML_ATTRIBUTES = {
				#'align'	=>	'right',
			}
			SYMBOL_MAP = {
				:navigation_divider	=>	HtmlGrid::Text,
			}
			include ExternalLinks
			def init
				build_navigation()
				super
			end
			def build_navigation(links = @lookandfeel.send(self::class::NAV_METHOD))
				links.each_with_index { |state, idx| 
					pos = [idx*2,0]
					if(state.is_a?(String))
						state = state.intern
					end
					#css_map.store(pos, self::class::NAV_LINK_CSS)
					component_css_map.store(pos, self::class::NAV_LINK_CSS)
					evt = if(state.is_a?(Symbol))
						unless(self.respond_to?(state))
							symbol_map.store(state, self::class::NAV_LINK_CLASS)
						end
						state
					else
						evt = state.direct_event
						symbol_map.store(evt, self::class::NAV_LINK_CLASS)
						evt
					end
					components.store(pos, evt)
					components.store([idx*2-1,0], :navigation_divider) if idx > 0
				}
			end
			def home(model)
				link = self.class::NAV_LINK_CLASS.new(:home_drugs, model, @session, self)
				link.value = @lookandfeel.lookup(:home)
				link
			end
		end
    class ZoneNavigation < Navigation
			NAV_METHOD = :zone_navigation
			NAV_LINK_CSS = 'navigation right'
      def build_navigation(links = [])
        links = @lookandfeel.zone_navigation.sort_by { |state|
          state = case state
                  when String, Symbol
                    state
                  else
                    state.direct_event
                  end
          @lookandfeel.lookup(state.to_sym).to_s.downcase
        }
        super(links)
      end
    end
	end
end
