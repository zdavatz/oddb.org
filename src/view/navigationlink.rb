#!/usr/bin/env ruby
# View::NavigationLink -- oddb -- 20.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/link'

module ODDB
	module View
		class NavigationLink < HtmlGrid::Link
			CSS_CLASS = "navigation"
			def init
				super
				unless (@lookandfeel.direct_event == @name)
					@attributes.store("href", @lookandfeel._event_url(@name))
				end
			end
		end
		class LanguageNavigationLink < HtmlGrid::Link
			CSS_CLASS = "list"
			def init
				super
				unless (@lookandfeel.language == @name.to_s)
					@attributes.store("href", @lookandfeel.language_url(@name))
				end
			end
		end
		class CurrencyNavigationLink < HtmlGrid::Link
			CSS_CLASS = "list"
			def init
				super
				unless (@session.currency == @name.to_s)
					args = {
						:currency => @name
					}
					@attributes.store("href", @lookandfeel._event_url(:self, args))
				end
			end
		end
	end
end
