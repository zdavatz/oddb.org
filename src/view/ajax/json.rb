#!/usr/bin/env ruby
# View::Ajax::Json -- oddb -- 22.06.2006 -- hwyss@ywesee.com

require 'htmlgrid/component'
require 'json'

module ODDB
  module View
    module Ajax
class Json < HtmlGrid::Component
  HTTP_HEADERS = {
    'Content-Type'  =>  'text/javascript; charset=UTF-8',
  }
  def to_html(context)
    @model.to_json
  end
end
    end
  end
end
