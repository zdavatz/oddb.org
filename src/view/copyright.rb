#!/usr/bin/env ruby

# ODDB::View::Copyright -- oddb.org -- 12.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Copyright -- oddb.org -- 27.05.2003 -- mhuggler@ywesee.com

require "htmlgrid/composite"
require "htmlgrid/link"
require "htmlgrid/datevalue"

module ODDB
  module View
    class Copyright < HtmlGrid::Composite
      COMPONENTS = {
        [0, 0]	=> :current_year,
        [1, 0]	=>	:oddb_version
      }
      LEGACY_INTERFACE = false
      def oddb_version(model)
        link = standard_link(:oddb_version, model)
        link.href = "https://github.com/zdavatz/oddb.org"
        link.set_attribute("title", link.href)
        link
      end

      def current_year(model)
        link = standard_link(:oddb_version, model)
        link.value = Time.now.year.to_s
        link.href = @lookandfeel.lookup(:cpr_link)
        link.set_attribute("title", link.href)
        link
      end

      def standard_link(key, model)
        klass = if @lookandfeel.enabled?(:popup_links, false)
          HtmlGrid::PopupLink
        else
          HtmlGrid::Link
        end
        klass.new(key, model, @session, self)
        # link.css_class = 'navigation'
      end
    end
  end
end
