#!/usr/bin/env ruby
require "htmlgrid/composite"
require "view/sponsorlogo"
require "view/google_ad_sense"
require "view/personal"
require "view/tab_navigation"
require "view/searchbar"
require "htmlgrid/link"
require "view/language_chooser"
require "view/logo"

module ODDB
  module View
    module SponsorDisplay
      include Personal
      include GoogleAdSenseMethods
      CSS_CLASS = "composite"
      GOOGLE_CHANNEL = "6336403681"
      GOOGLE_FORMAT = "468x60_as"
      GOOGLE_WIDTH = "468"
      GOOGLE_HEIGHT = "60"
    end

    class CommonLogoHead < HtmlGrid::Composite
      include Personal
      include SponsorDisplay
      include UserSettings
    end

    class LogoHead < CommonLogoHead
      COMPONENTS = {
        [0, 0] => View::Logo,
        [1, 0] => :personal_logo,
        [0, 1] => :language_chooser,
        [1, 1] => :tab_navigation
      }
      CSS_MAP = {
        [0, 1] => "list",
        [1, 0] => "right",
        [1, 1] => "tabnavigation"
      }
      COMPONENT_CSS_MAP = {
        [0, 0] => "welcomeleft"
      }
      def init
        super
        @components.delete([1, 0]) unless sponsor_or_logo
        # puts "LogoHead for #{@session.request_path} #{@components}"
      end

      def language_chooser(model, session = @session)
        # We do not want the language_chooser to be displayed when displaying results
        nil
      end

      def tab_navigation(model, session = @session)
        unless @lookandfeel.disabled?(:search_result_head_navigation)
          View::TabNavigation.new(model, session, self)
        end
      end
    end
  end
end
