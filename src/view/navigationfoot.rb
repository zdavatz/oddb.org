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
				[0,0]	=>	'list navigation',
				[1,0]	=>	'list navigation right',
				[0,1]	=>	'list subheading',
				[1,1]	=>	'list subheading right',
			}
			COMPONENT_CSS_MAP = {
				[0,0]	=>	'navigation',
				[1,0]	=>	'navigation right',
				[0,1]	=>	'atc',
				[1,1]	=>	'atc right',
			}
      def init
        if(@lookandfeel.enabled?(:custom_navigation, false) \
					|| @lookandfeel.zone_navigation.empty?)
          @components = {
            [0,0]		=>	View::Copyright,
            [1,0]		=>	View::Navigation,
          }
          @css_map = {
            [0,0]	=>	'list subheading',
            [1,0]	=>	'list subheading right',
          }
          @component_css_map = {
            [0,0]	=>	'atc',
            [1,0]	=>	'atc right',
          }
        end
        super
      end
		end
	end
end
