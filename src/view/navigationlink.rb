#!/usr/bin/env ruby
# View::NavigationLink -- oddb -- 20.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/link'

module ODDB
	module View
		class NavigationLink < HtmlGrid::Link
			CSS_CLASS = "navigation"
			def init
				super
				unless(@lookandfeel.direct_event == @name)
					@attributes.store("href", @lookandfeel._event_url(@name))
				end
			end
			def to_html(context)
				super
			end
		end
		class LanguageNavigationLink < HtmlGrid::Link
			CSS_CLASS = "list"
			def init
				super
				unless(@lookandfeel.language == @name.to_s)
					path = @session.request_path.dup
					path.gsub!(/^.{0,3}/, "/#{@name}")
					@attributes.store("href", path)
				end
			end
		end
		class CurrencyNavigationLink < HtmlGrid::Link
			CSS_CLASS = "list"
			def init
				super
				current = @session.currency
				unless(current == @name.to_s)
					path = @session.request_path.dup
					path.slice!(/\/$/)
					if(path.count('/') < 3)
						args = { :currency => @name }
						path = @lookandfeel._event_url(:self, args)
					else
						path.slice!(/\/currency\/[^\/]*/)
						path << '/currency/' << @name.to_s
					end
					@attributes.store("href", path)
				end
			end
		end
	end
end
