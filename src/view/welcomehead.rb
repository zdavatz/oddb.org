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
      }
      COMPONENT_CSS_MAP = {
        [0,0]	=>	'welcomeleft',
        [1,0] =>  'welcomecenter',
        [2,0] =>  'welcomeright',
      }
      def init
        super
        if (info = sponsor_or_logo)        
          if /home/.match(@session.request_path)
            @components[[0,0]] = '&nbsp;' # remove left logo
          else
            @components[[1,0]] = '&nbsp;' # remove middle logo
          end
        else
            @components[[0,0]] = '&nbsp;'
            @components[[2,0]] = '&nbsp;'
        end
        # puts "WelcomeHead #{info} for #{@session.request_path} => #{@components} #{@css_class}"
        super
      end
    end
	end
end
