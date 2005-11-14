#!/usr/bin/env ruby
# View::Navigation -- oddb -- 21.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/link'
require 'view/navigationlink'

module ODDB
	module View
		class Navigation < HtmlGrid::Composite
			COMPONENTS = {}
			CSS_CLASS = "navigation-right"
			LEGACY_INTERFACE = false
			NAV_LINK_CLASS = NavigationLink
			NAV_LINK_CSS = 'navigation'
			NAV_METHOD = :navigation
			HTML_ATTRIBUTES = {
				'align'	=>	'right',
			}
			SYMBOL_MAP = {
				:navigation_divider	=>	HtmlGrid::Text,
			}
			def init
				build_navigation()
				super
			end
			def build_navigation
				@lookandfeel.send(self::class::NAV_METHOD).each_with_index { |state, idx| 
					pos = [idx*2,0]
					if(state.is_a?(String))
						state = state.intern
					end
					evt = if(state.is_a?(Symbol))
						if(self.respond_to?(state))
							css_map.store(pos, self::class::NAV_LINK_CSS)
							component_css_map.store(pos, self::class::NAV_LINK_CSS)
						else
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
			def faq_link(model)
				wiki_link(model, :faq_link, :faq_pagename)
			end
			def help_link(model)
				wiki_link(model, :help_link, :help_pagename)
			end
			def wiki_link(model, key, namekey)
				name = @lookandfeel.lookup(namekey)
				link = HtmlGrid::Link.new(key, model, @session, self)
				link.href = "http://wiki.oddb.org/wiki.php?pagename=#{name}"
				link
			end
			## meddrugs_update, data_declaration and legal_note: 
			## extrawurst for just-medical
			def data_declaration(model)
				wiki_link(model, :data_declaration, :datadeclaration_pagename)
			end
			def legal_note(model)
				wiki_link(model, :legal_note, :legal_note_pagename)
			end
			def home(model)
				link = NavigationLink.new(:home_drugs, model, @session, self)
				link.value = @lookandfeel.lookup(:home)
				link
			end
			def meddrugs_update(model)
				link = NavigationLink.new(:meddrugs_update, 
					model, @session, self)
				link.href = "http://www.just-medical.ch/jm.cfm?top=just-medical/top_home.cfm&menu=meddrugs/menu_drugs.cfm&main=meddrugs/update.cfm&l1=05&l2=45&l3=1&r1=05&r2=45&r3=1"
				link
			end
		end
	end
end
