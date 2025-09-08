#!/usr/bin/env ruby

# View::NavigationLink -- oddb -- 20.11.2002 -- hwyss@ywesee.com

require "htmlgrid/link"

module ODDB
  module View
    class NavigationLink < HtmlGrid::Link
      CSS_CLASS = "navigation"
      def init
        super
        unless @lookandfeel.direct_event == @name
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
        lang = @lookandfeel.language
        unless lang == @name.to_s
          path = @session.request_path.dup
          base = "/#{@name}/"
          path.sub!(%r{/#{lang}/?}u, base) || path = base
          @attributes.store("href", path)
        end
      end
    end

    class LanguageNavigationLinkShort < LanguageNavigationLink
      def init
        super
        @value = @name.to_s.capitalize
      end
    end
  end
end
