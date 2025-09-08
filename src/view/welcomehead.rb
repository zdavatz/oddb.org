#!/usr/bin/env ruby
require "htmlgrid/composite"
require "htmlgrid/text"
require "htmlgrid/link"
require "view/logohead"

module ODDB
  module View
    class WelcomeHead < HtmlGrid::Composite
      include Personal
      include SponsorDisplay
      LOGO_PATH = File.join(ODDB::RESOURCES_DIR, "logos")
      CSS_CLASS = "composite"
      CSS_MAP = {
        [0, 0]	=>	"welcomeleft",
        [1, 0] => "welcomecenter",
        [2, 0] => "right"
      }
      COMPONENTS = {
        [0, 0] => View::Logo,
        [1, 0] => View::Logo,
        [2, 0] => :personal_logo,
        [0, 1] => "&nbsp;"
      }
      COMPONENT_CSS_MAP = {
        [0, 0] => "welcomeleft",
        [2, 0] => "right"
      }
      def init
        super
        # POST method is used when requesting a poweruser login
        if (is_at_home || /home/.match(@session.request_path)) && !@session.request_method.eql?("POST")
          @components[[0, 0]] = "&nbsp;" # remove left logo
          @components[[2, 0]] = "&nbsp;" # remove right logo
        else
          @components[[1, 0]] = "&nbsp;" # remove middle logo
        end
        unless sponsor_or_logo
          # remove right logo
          @components[[2, 0]] = "&nbsp;" unless @session.request_method.eql?("POST")
        end
        super
      end
    end
  end
end
