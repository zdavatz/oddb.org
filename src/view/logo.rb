#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Logo -- oddb.org -- 04.10.2012 -- yasaka@ywesee.com
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
          src = zone_logo_src(self::class::LOGO_KEY)
          if (@session.flavor == Session::DEFAULT_FLAVOR or \
              @session.lookandfeel.enabled?(:preferences)) and
             style = @session.get_cookie_input(:style) and
             style != "default" and
             @lookandfeel.attributes(:styles).keys.include?(style)
            src.gsub!(/logo\.png/, "logo_#{style}.png")
          end
          @attributes['src'] = src
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
