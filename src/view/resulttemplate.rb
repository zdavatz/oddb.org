#!/usr/bin/env ruby

# View::ResultTemplate -- oddb -- 20.10.2004 -- jlang@ywesee.com

require "view/publictemplate"
require "view/navigation"
require "view/welcomehead"
require "view/logohead"
require "view/tab_navigationlink"

module ODDB
  module View
    class ResultTemplate < PublicTemplate
      HEAD = View::WelcomeHead
      COMPONENTS = {}
      def init
        @components = {
          [0, 0]	=>	:head,
          [0, 1]	=>	:tab_navigation,
          [0, 2]	=>	:content,
          [0, 3]	=>	:foot
        }
        super
      end

      def tab_navigation(model, session = @session)
        unless @lookandfeel.disabled?(:search_result_head_navigation)
          View::TabNavigation.new(model, session, self)
        end
      end
    end
  end
end
