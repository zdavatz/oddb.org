#!/usr/bin/env ruby
# Logo -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/component'

module ODDB
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
			context.img(@attributes)
		end
	end
	class Logo < PopupLogo
		def to_html(context)
			if(@lookandfeel.enabled?(:logo))
				super
			else
				'&nbsp;'
			end
		end
	end
end
