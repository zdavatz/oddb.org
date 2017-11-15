#!/usr/bin/env ruby
# encoding: utf-8

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'htmlgrid/link'
require 'view/logohead'

module ODDB
  module View
    class WelcomeHead < HtmlGrid::Composite
      include Personal
      include SponsorDisplay
      LOGO_PATH = File.expand_path('../../../doc/resources/logos', File.dirname(__FILE__))
      CSS_CLASS = 'composite'
      CSS_MAP = {
        [0,0]	=>	'welcomeleft',
        [1,0] =>  'welcomecenter',
        [2,0] =>  'welcomeright',
      }
      COMPONENTS = {
        [0,0] => View::Logo,
        [1,0] => View::Logo,
        [2,0] => :personal_logo,
        [0,1] => '&nbsp;',
      }
      COMPONENT_CSS_MAP = {
        [0,0] =>  'welcomeleft',
        [2,0] =>  'welcomeright',
      }
      def init
        super
        if is_at_home || /home/.match(@session.request_path)
          @components[[0,0]] = '&nbsp;' # remove left logo
          @components[[2,0]] = '&nbsp;' # remove right logo
        else
          @components[[1,0]] = '&nbsp;' # remove middle logo
        end
        unless sponsor_or_logo
          @components[[2,0]] = '&nbsp;' # remove right logo
        end
        # puts "WelcomeHead #{is_at_home} for #{@session.request_path} => #{@components} #{@css_class} #{@session.user}"
        super
      end
    end
	end
end
