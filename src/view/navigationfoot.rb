#!/usr/bin/env ruby
# View::NavigationFoot -- oddb -- 19.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'view/navigation'
require 'view/copyright'

module ODDB
	module View
		class NavigationFoot < HtmlGrid::Composite
			CSS_CLASS = "composite"
			COMPONENTS = {
				[1,0]		=>	View::ZoneNavigation,
				[0,1]		=>	View::Copyright,
				[1,1]		=>	View::Navigation,
			}
			CSS_MAP = {
				[0,0]	=>	'navigation',
				[1,0]	=>	'navigation right',
				[0,1]	=>	'subheading',
				[1,1]	=>	'subheading right',
			}
			COMPONENT_CSS_MAP = {
				[0,0]	=>	'navigation',
				[1,0]	=>	'navigation right',
				[0,1]	=>	'subheading',
				[1,1]	=>	'subheading right',
			}
      def init
        if(@lookandfeel.disabled?(:navigation))
          @components = {
            [0,0]		=>	View::Copyright,
          }
          @css_map = {
            [0,0]	=>	'subheading',
          }
          @component_css_map = {
            [0,0]	=>	'subheading',
          }
        elsif(@lookandfeel.disabled?(:zone_navigation))
          @components = {
            [0,0]		=>	View::Copyright,
            [1,0]		=>	View::Navigation,
          }
          @css_map = {
            [0,0]	=>	'navigation',
            [1,0]	=>	'navigation right',
          }
          @component_css_map = {
            [0,0]	=>	'navigation',
            [1,0]	=>	'navigation right',
          }
        elsif(@lookandfeel.enabled?(:custom_navigation, false) \
					 || @lookandfeel.zone_navigation.empty?)
          @components = {
            [0,0]		=>	View::Copyright,
            [1,0]		=>	View::Navigation,
          }
          @css_map = {
            [0,0]	=>	'subheading',
            [1,0]	=>	'subheading right',
          }
          @component_css_map = {
            [0,0]	=>	'subheading',
            [1,0]	=>	'subheading right',
          }
        elsif(@lookandfeel.enabled?(:country_navigation))
          components.store([0,0], View::CountryNavigation)
        end
        if(@lookandfeel.enabled?(:google_analytics))
          components.store([0,0,1], :google_analytics)
        end
        super
      end
      def google_analytics(model, session=@session)
        div = HtmlGrid::Div.new(model, @session, self)
        div.attributes.update('dojoType' => 'dojox.analytics.Urchin',
                              'acct'     => 'UA-115196-1')
        div
      end
		end
    class TopFoot < HtmlGrid::Composite
      CSS_CLASS = "composite"
      COMPONENTS = {
        [1,0] =>	View::ZoneNavigation,
      }
      CSS_MAP = {
        [0,0]	=>	'navigation',
        [1,0]	=>	'navigation right',
      }
      COMPONENT_CSS_MAP = {
        [0,0]	=>	'navigation',
        [1,0]	=>	'navigation right',
      }
      def init
        if(@lookandfeel.enabled?(:country_navigation))
          components.store([0,0], View::CountryNavigation)
        end
        super
      end
    end
	end
end
