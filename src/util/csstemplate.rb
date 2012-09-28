#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'

module ODDB
  class CssTemplate
    RESOURCE_PATH = "../../doc/resources/"
    TEMPLATE = File.expand_path('../../data/css/template.css', File.dirname(__FILE__))
    FLAVORS = {
      :atupri => {
        :bg                         => '#d5e4f1',
        :bg_bright                  => '#ACD0F0',
        :bg_medium                  => '#6699CC',
        :bg_medium_font_color       => 'black',
        :bg_dark                    => '#3F008E',
        :bg_dark_font_color         => 'white',
        :bg_dark_link_hover_color   => '#e20a16',
        :bg_dark_link_active_color  => '#e20a16',
        :bg_navigation              => '#3F008E',
        :home_link_color            => '#3F008E',
        :home_link_hover_color      => '#e20a16',
        :list_font_color            => '#3F008E',
        :list_link_color            => '#3F008E',
        :list_link_hover_color      => '#e20a16',
        #:rslt_bg                   => '#ACD0F0',
        :navigation_font_color      => 'white',
        :navigation_link_font_color => 'white',
        :rslt_link_hover_color      => '#6666CC',
      },
      :desitin => {
        :bg_dark                         => '#1b49a2',
        :bg_bright                       => '#d8e1f3',
        :bg_navigation                   => '#1b49a2',
        :rslt_bg                         => '#f6f8fc',
        :bg_dark_link_hover_color        => '#d8e1f3',
        :bg_dark_link_active_color       => '#d8e1f3',
        :navigation_font_color           => 'white',
        :subheading_link_color           => 'white',
        :subheading_link_active_color    => '#d8e1f3',
        :subheading_link_hover_color     => '#d8e1f3',
        :tabnavigation_link_active_color => 'white',
        :tabnavigation_link_color        => 'white',
      },
      :'just-medical' => {
        :bg                         => '#fdeeb8',
        :bg_bright                  => '#e5c237',
        :bg_bright_font_color       => 'black',
        :bg_dark                    => '#d4b126',
        :bg_dark_font_color         => 'black',
        :bg_dark_link_hover_color   => 'red',
        :bg_dark_link_active_color  => 'red',
        :bg_navigation              => '#d4b126',
        :home_link_color            => 'black',
        :home_link_hover_color      => 'red',
        :list_font_color            => 'black',
        :list_link_hover_color      => 'blue',
        :navigation_font_color      => 'black',
        :navigation_link_font_color => 'black',
        :rslt_bg                    => '#fae596',
      },
      :gcc => {
      },
      :generika => {
      },
      :hirslanden => {
        :bg_bright                  => '#cdf',
        :bg_bright_font_color       => '#333',
        :bg_dark                    => '#69c',
        :bg_dark_font_color         => 'black',
        :bg_dark_link_hover_color   => 'white',
        :bg_medium                  => '#8be',
        :bg_navigation              => '#69c',
        :button_font_size           => '10px',
        :home_link_color            => '#69c',
        :home_link_hover_color      => 'red',
        :list_font_color            => 'black',
        :navigation_font_color      => 'black',
        :navigation_font_size       => '11px',
        :navigation_link_font_color => 'black',
        :std_font_size              => '11px',
      },
      :innova => {
        :bg_bright                  => '#d9fed5',
        :bg_dark                    => '#99ccff',
        :bg_dark_font_color         => 'black',
        :bg_dark_link_hover_color   => 'red',
        :bg_navigation              => '#99ccff',
        :button_background          => '#99ccff',
        :button_font_size           => '11px',
        :home_link_color            => '#5a9ad6',
        :home_link_hover_color      => 'red',
        :list_font_color            => 'black',
        :list_link_hover_color      => '#5a9ad6',
        :navigation_font_color      => 'black',
        :navigation_link_font_color => 'black',
        :navigation_font_size       => '11px',
        :std_font_size              => '11px',
      },
      :'medical-tribune' => {
        :bg_bright                  => '#99A8FF',
        :bg_dark                    => '#2B47A4',
        :bg_dark_link_active_color  => 'red',
        :bg_dark_link_hover_color   => 'black',
        :bg_navigation              => '#CCCCCC',
        :big_font_size              => '12px',
        :navigation_font_color      => 'white',
        :navigation_link_font_color => 'blue',
        :std_font_family            => 'Verdana, Arial, Helvetica, sans-serif',
      },
      :'medical-tribune1' => {
        :bg_bright                  => '#FFD899',
        :bg_dark                    => '#FF9900',
        :bg_dark_link_active_color  => 'red',
        :bg_dark_link_hover_color   => 'black',
        :bg_navigation              => '#FFCC66',
        :big_font_size              => '12px',
        :list_link_hover_color      => '#FF9900',
        :navigation_font_color      => 'white',
        :navigation_link_font_color => 'blue',
        :std_font_family            => 'Verdana, Arial, Helvetica, sans-serif',
      },
      :mobile    =>    {
        :explain_font_size => '12px',
        :infos_height      => '16px',
      },
      :provita => {
        :bg_bright                => '#c9eec5',
        :bg_dark                  => '#4b8e52',
        :bg_dark_link_hover_color => 'red',
        :bg_navigation            => '#4b8e52',
        :button_background        => '#4b8e52',
        :button_font_color        => 'white',
        :button_font_size         => '10px',
        :home_link_color          => '#4b8e52',
        :home_link_hover_color    => 'red',
        :list_font_color          => 'black',
        :navigation_font_size     => '11px',
        :std_font_size            => '11px',
      },
      :santesuisse => {
        :bg_bright                   => '#eaf1fd',
        :bg_medium                   => '#AAA',
        :bg_medium_font_color        => 'white',
        :bg_dark                     => '#4b81d4',
        :bg_dark_font_color          => 'white',
        :bg_dark_link_hover_color    => '#c8d8f0',
        :bg_dark_link_active_color   => '#c8d8f0',
        :bg_navigation               => '#4b81d4',
        :button_background           => 'white',
        :button_font_color           => 'black',
        :button_font_size            => '10px',
        :home_link_color             => '#5185d5',
        :home_link_hover_color       => '#3a64a4',
        :list_font_color             => 'black',
        :list_link_color             => 'black',
        :list_link_hover_color       => '#4b81d4',
        :navigation_link_font_weight => 'bold',
      },
      :swissmedic => {
      },
      :swissmedinfo => {
        :bg_dark                  => '#A04',
        :bg_bright                => '#ECC',
        :bg_navigation            => '#A04',
        :body_margin              => '4px',
        :explain_font_size        => '15px',
        :h3_font_size             => '20px',
        :h3_margin                => '6px',
        :pre_font_size            => '20px',
        :bg_dark_link_hover_color => '#999',
        :square_font_size         => '12px',
        :navigation_font_size     => '14px',
        :std_font_size            => '14px',
      },
      :anthroposophy => {
        :bg_bright                 => '#fcf',
        :bg_medium                 => '#e6f',
        :bg_dark                   => '#f0f',
        :bg_navigation             => '#f0f',
        :bg_dark_font_color        => 'white',
        :bg_dark_link_hover_color  => '#608',
        :bg_dark_link_active_color => '#608',
        :bg_medium_font_color      => 'black',
        :home_link_color           => '#20b',
        :home_link_hover_color     => '#40d',
        :list_link_color           => 'black',
        :list_link_hover_color     => '#20b',
        :rslt_infos_bg_bright      => '#fff88f',
        :rslt_infos_bg_dark        => '#fff455',
      },
      :homeopathy => {
        :bg_bright                 => '#ecf',
        :bg_medium                 => '#b6f',
        :bg_dark                   => '#90f',
        :bg_navigation             => '#90f',
        :bg_dark_font_color        => 'white',
        :bg_dark_link_hover_color  => '#304',
        :bg_dark_link_active_color => '#304',
        :bg_medium_font_color      => 'black',
        :home_link_color           => '#20b',
        :home_link_hover_color     => '#40d',
        :list_link_color           => 'black',
        :list_link_hover_color     => '#20b',
        :rslt_infos_bg_bright      => '#fff88f',
        :rslt_infos_bg_dark        => '#fff455',
      },
      :'phyto-pharma' => {
        :bg_bright                 => '#dcf',
        :bg_medium                 => '#a6f',
        :bg_dark                   => '#60f',
        :bg_dark_font_color        => 'white',
        :bg_dark_link_hover_color  => '#dcf',
        :bg_dark_link_active_color => '#dcf',
        :bg_medium_font_color      => 'black',
        :bg_navigation             => '#60f',
        :home_link_color           => '#20b',
        :home_link_hover_color     => '#40d',
        :list_link_color           => 'black',
        :list_link_hover_color     => '#20b',
        :rslt_infos_bg_bright      => '#fff88f',
        :rslt_infos_bg_dark        => '#fff455',
      },
    }
    STYLES = { # gcc
      :blue  => {
        :bg_bright                       => '#a0a0ff',
        :bg_dark                         => '#0000ff',
        :bg_dark_link_active_color       => 'black',
        :bg_dark_link_hover_color        => 'blue',
        :atc_link_color                  => '#0000ff',
        :bg_navigation                   => '#0000ff',
        :generic_font_color              => '#0000ff',
        :home_link_hover_color           => 'black',
        :list_link_hover_color           => 'black',
        :rslt_bg                         => '#f0f8ff',
        :sidebar_color                   => '#f0f8ff',
        :tabnavigation_link_active_color => 'black',
        :tabnavigation_link_color        => 'blue',
        :tabnavigation_link_hover_color  => 'black',
        :tabnavigation_text_color        => 'black',
      },
      :red => {
        :bg_bright                       => '#d35f5f',
        :bg_dark                         => '#501616',
        :bg_dark_link_active_color       => 'black',
        :bg_dark_link_hover_color        => 'red',
        :atc_link_color                  => '#501616',
        :bg_navigation                   => '#501616',
        :generic_font_color              => '#501616',
        :home_link_hover_color           => '#501616',
        :list_link_hover_color           => '#501616',
        :rslt_bg                         => '#fff0f5',
        :sidebar_color                   => '#fff0f5',
        :tabnavigation_link_active_color => 'black',
        :tabnavigation_link_color        => 'white',
        :tabnavigation_link_hover_color  => 'black',
        :tabnavigation_text_color        => 'black',
      },
      :olive => {
        :bg_bright                       => '#c2c261',
        :bg_dark                         => '#747400',
        :bg_dark_link_active_color       => 'black',
        :bg_dark_link_hover_color        => 'blue',
        :atc_link_color                  => '#747400',
        :bg_navigation                   => '#747400',
        :generic_font_color              => '#747400',
        :home_link_hover_color           => 'red',
        :list_link_hover_color           => 'red',
        :rslt_bg                         => '#f5f5dc',
        :sidebar_color                   => '#f5f5dc',
        :tabnavigation_link_active_color => 'red',
        :tabnavigation_link_color        => 'blue',
        :tabnavigation_link_hover_color  => 'black',
        :tabnavigation_text_color        => 'black',

      },
    }
    DEFAULT = {
      :align_center                    => 'center',
      :align_center_inputmargin        => '7px',
      :align_center_tablemargin        => 'auto',
      :atc_link_color                  => '#2ba476',
      :bg_bright                       => '#ccff99',
      :bg_bright_font_color            => 'black',
      :bg_dark                         => '#2ba476',
      :bg_dark_font_color              => 'white',
      :bg_dark_link_active_color       => 'red',
      :bg_dark_link_hover_color        => 'blue',
      :bg_feedback                     => '#ffbc6f',
      :bg_feedback_alternate           => '#ffbc22',
      :bg_google                       => '#184fca',
      :bg_medium                       => '#7bcf88',
      :bg_medium_font_color            => 'black',
      :bg_navigation                   => '#2ba476',
      :bg                              => 'white',
      :big_font_size                   => '14px',
      :body_margin                     => '8px',
      :button_background               => 'none',
      :button_font_color               => 'black',
      :button_font_size                => '12px',
      :explain_font_size               => '11px',
      :generic_font_color              => '#2ba476',
      :h3_font_size                    => '12px',
      :h3_margin                       => '2px',
      :home_link_color                 => 'blue',
      :home_link_hover_color           => '#2ba476',
      :infos_height                    => 'auto',
      :l1_font_size                    => '12px',
      :l2_font_size                    => '14px',
      :l3_font_size                    => '16px',
      :list_font_color                 => 'blue',
      :list_link_color                 => 'blue',
      :list_link_hover_color           => '#2ba476',
      :navigation_link_font_color      => 'white',
      :navigation_link_font_weight     => 'normal',
      :navigation_font_color           => 'white',
      :navigation_font_size            => '12px',
      :pre_font_size                   => '12px',
      :rslt_bg                         => '#ecffe6',
      :rslt_infos_bg_bright            => '#FFF88F',
      :rslt_infos_bg_dark              => '#FFF455',
      :rslt_link_active_color          => 'gold',
      :rslt_link_hover_color           => 'blue',
      :sidebar_color                   => '#ddffdd',
      :square_font_size                => '11px',
      :std_font_family                 => 'Arial, Helvetica, sans-serif',
      :std_font_size                   => '12px',
      :subheading_link_color           => 'black',
      :subheading_link_active_color    => 'silver',
      :subheading_link_hover_color     => 'red',
      :tabnavigation_link_active_color => 'black',
      :tabnavigation_link_color        => 'blue',
      :tabnavigation_link_font_size    => '13px',
      :tabnavigation_link_font_weight  => 'bold',
      :tabnavigation_link_hover_color  => 'black',
      :tabnavigation_text_color        => 'black',
    }
    class << self
      def flavor_path(name)
        path = RESOURCE_PATH + "#{name}/oddb.css"
        File.expand_path(path, File.dirname(__FILE__))
      end
      def style_path(name)
        path = RESOURCE_PATH + "gcc/oddb-#{name}.css"
        File.expand_path(path, File.dirname(__FILE__))
      end
      def resolve(var, flavor)
        key = var.intern
        flavor.fetch(key) {
          DEFAULT.fetch(key) { raise "could not find default for #{key}" }
        }
      end
      def substitute(src, flavor)
        src.gsub(/\$([^\s;]+)/u) { |match|
          resolve($1, flavor)
        }
      end
      def write_css()
        {
          :flavor => FLAVORS,
          :style  => STYLES
        }.each_pair do |type, css|
          css.each { |name, updates|
            src =  File.read(TEMPLATE)
            path = self.send("#{type}_path".intern, name)
            FileUtils.mkdir_p(File.dirname(path))
            File.open(path, "w") { |fh|
              fh << substitute(src, updates)
            }
            File.chmod(0664, path)
            puts path
          }
        end
      end
    end
  end
end
