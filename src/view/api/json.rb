#!/usr/bin/env ruby

# View::Api::Json -- oddb -- 12.04.2012 -- yasaka@ywesee.com

require "htmlgrid/component"
require "json"

module ODDB
  module View
    module Api
      class Json < HtmlGrid::Component
        HTTP_HEADERS = {
          "Content-Type" => "text/javascript; charset=UTF-8"
        }
        def to_html(context)
          @model.to_json
        end
      end
    end
  end
end
