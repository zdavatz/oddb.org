#!/usr/bin/env ruby
# View::Logo -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/component'

module ODDB
	module View
		class PopupLogo < HtmlGrid::Component
			CSS_CLASS = 'logo'
			def init
				super
				if(@lookandfeel)
					@attributes.update(@lookandfeel.attributes(:logo))
					@attributes['src'] = if(@lookandfeel.enabled?(:multilingual_logo, false))
						@lookandfeel.resource_localized(:logo)
					else
						@lookandfeel.resource(:logo)
					end
					@attributes['alt'] = @lookandfeel.lookup(:logo)
				end
			end
			def to_html(context)
				link_attrs = {
					"href"	=> @lookandfeel.event_url(:home)
				}
				context.a(link_attrs) {
					context.img(@attributes)
				}
			end
		end
		class Logo < View::PopupLogo
			def to_html(context)
				if(@lookandfeel.enabled?(:logo))
					super
				else
					'&nbsp;'
				end
			end
		end
	end
end
