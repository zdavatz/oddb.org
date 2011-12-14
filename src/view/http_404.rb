#!/usr/bin/env ruby
# encoding: utf-8
# View::Http404 -- oddb.org -- 22.05.2007 -- hwyss@ywesee.com

require 'view/publictemplate'

module ODDB
  module View
    class Http404Composite < HtmlGrid::Composite
      CSS_CLASS = 'composite'
      COMPONENTS = {
        [0,1] => 'http_404',
      }
      CSS_MAP = {
        [0,0] => 'th',
        [0,1] => 'error',
      }
    end
    class Http404 < PublicTemplate
      CONTENT = Http404Composite
    end
  end
end
