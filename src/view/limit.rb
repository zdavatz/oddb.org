#!/usr/bin/env ruby

# View::Limit -- oddb -- 26.07.2005 -- hwyss@ywesee.com

require "view/resulttemplate"
require "view/logohead"

module ODDB
  module View
    class LimitComposite < HtmlGrid::Composite
      COMPONENTS = {
        [0, 0] => :query_limit,
        [0, 1] => :query_limit_explain,
        [0, 2] => :swiyu_login_link
      }
      CSS_MAP = {
        [0, 0] => "th",
        [0, 1] => "list",
        [0, 2] => "list"
      }
      CSS_CLASS = "composite"
      LEGACY_INTERFACE = false

      def query_limit(model)
        @lookandfeel.lookup(:query_limit,
          @session.class.const_get(:QUERY_LIMIT))
      end

      def query_limit_explain(model)
        @lookandfeel.lookup(:query_limit_explain, @session.remote_ip,
          @session.class.const_get(:QUERY_LIMIT))
      end

      def swiyu_login_link(model)
        @lookandfeel.lookup(:swiyu_login_link)
      end
    end

    class Limit < ResultTemplate
      CONTENT = LimitComposite
    end
  end
end
