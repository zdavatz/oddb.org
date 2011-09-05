#!/usr/bin/env ruby
# ODDB::View::Logo -- oddb.org -- 05.09.2011 -- mhatakeyama@ywesee.com 
# ODDB::View::Logo -- oddb.org -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/component'

module ODDB
	module View
		class PopupLogo < HtmlGrid::Component
			CSS_CLASS = 'logo'
			LOGO_KEY = :logo
			def init
				super
				if(@lookandfeel)
					@attributes.update(@lookandfeel.attributes(self::class::LOGO_KEY))
					@attributes['src'] = zone_logo_src(self::class::LOGO_KEY)
					@attributes['alt'] = @lookandfeel.lookup(self::class::LOGO_KEY)
				end
			end
			def to_html(context)
        link_attrs = if attrs = @lookandfeel.attributes(:logo) and href = attrs['href']
                       { "href"	=> href }
                     else
                       { "href"	=> @lookandfeel._event_url(:home) }
                     end
				context.a(link_attrs) {
					context.img(@attributes)
				}
			end
			def logo_src(key)
				if(@lookandfeel.enabled?(:multilingual_logo, false))
					@lookandfeel.resource_localized(key)
				else
					@lookandfeel.resource(key)
				end
			end
			def zone_logo_src(key)
				src = if(@lookandfeel.enabled?(:zone_logo))
					zone_key = [key, @session.state.zone].join('_').intern
					logo_src(zone_key)
				end
				src || logo_src(key)
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
