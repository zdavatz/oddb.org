#!/usr/bin/env ruby

# View::PrivateTemplate -- oddb -- 23.10.2002 -- hwyss@ywesee.com

require	"view/form"
require "view/publictemplate"
require "view/pointersteps"
require "view/searchbar"

module ODDB
  module View
    class PrivateTemplate < PublicTemplate
      include View::Snapback
      SEARCH_HEAD = View::SearchForm
      def init
        reorganize_components
        super
      end

      def backtracking(model, session = @session)
        View::PointerSteps.new(model, @session, self)
      end

      def reorganize_components
        @components = {
          [0, 0]	=>	:head,
          [0, 1]	=>	:backtracking,
          [1, 1]	=>	self.class::SEARCH_HEAD,
          [0, 2]	=>	:content,
          [0, 3]	=>	:foot
        }
        @colspan_map = {
          [0, 0]	=>	2,
          [0, 2]	=>	2,
          [0, 3]	=>	2
        }
        css_map.store([1, 1], "right")
      end
    end
  end
end
