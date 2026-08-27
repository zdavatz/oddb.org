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
        # "center", damit die Sprachwahl unter dem Logo steht und nicht am
        # linken Rand - dieselbe Zelle traegt sie auf der Startseite mittig.
        [0, 1] => "list center",
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

      # Bis August 2026 stand hier ein nil mit der Begruendung "We do not want
      # the language_chooser to be displayed when displaying results". Auf dem
      # Telefon ist das die falsche Entscheidung: die Sprachwahl steht sonst
      # nur auf der Startseite, und wer aus einer Suchmaschine auf eine
      # Trefferliste kommt, hat sie nie gesehen. Sie kostet eine Zeile.
      def tab_navigation(model, session = @session)
        unless @lookandfeel.disabled?(:search_result_head_navigation)
          View::TabNavigation.new(model, session, self)
        end
      end
    end
  end
end
