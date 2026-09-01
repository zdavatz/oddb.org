#!/usr/bin/env ruby

# View::TabNavigation -- oddb -- 01.09.2004 -- mhuggler@ywesee.com

require "htmlgrid/composite"
require "htmlgrid/link"
require "view/tab_navigationlink"

module ODDB
  module View
    class TabNavigation < HtmlGrid::Composite
      COMPONENTS = {}
      CSS_CLASS = "component tabnavigation right"
      # HTML_ATTRIBUTES = { "align"=>"center" }
      SYMBOL_MAP = {
        tabnavigation_divider: HtmlGrid::Text
      }
      def init
        if @lookandfeel.enabled?(:custom_tab_navigation, false)
          build_custom_navigation
        else
          build_navigation
        end
        super
      end

      def build_navigation
        @lookandfeel.zones.sort_by { |zone|
          @lookandfeel.lookup(zone)
        }.each_with_index { |zone, idx|
          symbol_map.store(zone, View::TabNavigationLink)
          pos = [idx * 2, 0]
          components.store(pos, zone)
          component_css_map.store(pos, "tabnavigation")
          if idx > 0
            # Der Strich bekommt eine eigene Klasse, sonst erbt seine Zelle
            # td { font-size: 14px } und steht neben den 13px-fetten Links
            # sichtbar zu hoch. Ohne Klasse laesst er sich nicht ansprechen.
            divider = [idx * 2 - 1, 0]
            components.store(divider, :tabnavigation_divider)
            component_css_map.store(divider, "tabnavigation-divider")
          end
        }
      end

      def build_custom_navigation
        @lookandfeel.zones.each_with_index { |zone, idx|
          if zone.is_a?(Class)
            zone = zone.direct_event
            symbol_map.store(zone, View::NavigationLink)
          else
            symbol_map.store(zone, View::TabNavigationLink)
          end
          pos = [idx * 2, 0]
          components.store(pos, zone)
          component_css_map.store(pos, "tabnavigation")
          if idx > 0
            # Der Strich bekommt eine eigene Klasse, sonst erbt seine Zelle
            # td { font-size: 14px } und steht neben den 13px-fetten Links
            # sichtbar zu hoch. Ohne Klasse laesst er sich nicht ansprechen.
            divider = [idx * 2 - 1, 0]
            components.store(divider, :tabnavigation_divider)
            component_css_map.store(divider, "tabnavigation-divider")
          end
        }
      end

      def to_html(context)
        if components.empty?
          "&nbsp;"
        else
          super
        end
      end
    end
  end
end
