#!/usr/bin/env ruby
# encoding: utf-8
# View::PublicTemplate -- oddb -- 15.01.2013 -- yasaka@ywesee.com
# View::PublicTemplate -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/template'
require 'view/navigationfoot'
require 'sbsm/time'
require 'view/custom/head'
require 'view/logohead'
require 'view/htmlgrid/component'

DOJO_VERSION = "1.7.2"

module ODDB
	module View
		class PublicTemplate < HtmlGrid::Template
			include View::Custom::HeadMethods
			include HtmlGrid::DojoToolkit::DojoTemplate
      DOJO_DEBUG = false
      DOJO_ENCODING = 'UTF-8'
      DOJO_REQUIRE = [
        'dojo/ready',
        'dojo/parser',
        'dojo/io/script',
        'dojo/_base/window',
        'dojox/data/JsonRestStore',
        'dijit/form/ComboBox',
        'dijit/ProgressBar',
        'ywesee/widget/Tooltip',
      ]
      DOJO_PARSE_WIDGETS = false
      DOJO_PREFIX = {
        'ywesee' => '/resources/javascript/ywesee',
      }
			CONTENT = nil
			CSS_CLASS = "composite"
			COMPONENTS = {
				[0,0]		=>	:head,
				[0,1]		=>	:content,
				[0,2]		=>	:foot,
			}
			HEAD = View::LogoHead
			HTTP_HEADERS = {
				"Content-Type"	=>	"text/html; charset=UTF-8",
				"Cache-Control"	=>	"private, no-store, no-cache, must-revalidate, post-check=0, pre-check=0",
				"Pragma"				=>	"no-cache",
				"Expires"				=>	Time.now.rfc1123,
				"P3P"						=>	"CP='OTI NID CUR OUR STP ONL UNI PRE'",
			}
			FOOT = View::NavigationFoot
			META_TAGS = [
				{
					"name"				=>	"robots",
					"content"			=>	"follow, index, noarchive",
				},
			]
      def init
        @additional_javascripts = []
        super
      end
			def content(model, session)
				self::class::CONTENT.new(model, session, self)
			end
			def css_link(context, path=nil)
				if(@lookandfeel.enabled?(:external_css, false))
					super(context, @lookandfeel.resource_external(:external_css))
				else
					link = super
          if (@session.flavor == Session::DEFAULT_FLAVOR or \
              @session.lookandfeel.enabled?(:preferences)) and
             style = @session.get_cookie_input(:style) and
             style != "default" and
             @lookandfeel.attributes(:styles).keys.include?(style)
            link.gsub!(/oddb\.css/, "oddb-#{style}.css")
          end
          link
				end
			end
      def dynamic_html_headers(context)
        headers = super
        if(@lookandfeel.enabled?(:ajax))
          if @lookandfeel.enabled?(:google_analytics)
            headers << context.script('type' => 'text/javascript') do
              <<-EOS
require(['dojo/ready'], function(ready) {
  ready(function() {
    setTimeout(
      require(['dojox/analytics/Urchin'], function(analytics) {
        var tracker = new dojox.analytics.Urchin({
          acct: "UA-115196-1"
        })
      }),
      100
    );
  });
});
              EOS
            end
          end
        end
        # additional dojo css
        dojo_path = @lookandfeel.resource_global(:dojo_js)
        dojo_path ||= '/resources/dojo/dojo/dojo.js'
        dojo_dir = File.dirname(dojo_path)
        headers << context.style(:type => "text/css") { <<-EOS
            @import "#{File.join(dojo_dir, "../dijit/themes/tundra/ProgressBar.css")}";
          EOS
        }
        headers
      end
			def foot(model, session)
				self::class::FOOT.new(model, session, self) unless self::class::FOOT.nil?
			end
			def head(model, session)
				self::class::HEAD.new(model, session, self) unless self::class::HEAD.nil?
			end
      def javascripts(context)
        scripts = super
        @additional_javascripts.each do |script|
          args = {
            'type'     => 'text/javascript',
            'language' => 'JavaScript',
          }
          scripts << context.script(args) do script end
        end
        scripts
      end
			def title(context)
				context.title { 
					[
						@lookandfeel.lookup(:html_title),
						@lookandfeel.lookup(@session.state.zone),
						title_part_three(),
					].compact.join(@lookandfeel.lookup(:title_divider))
				}
			end
			def title_part_three
				event = @session.state.direct_event || @session.event
				if([nil, :resolve, :login, :update, :delete].include?(event))
					if(@model.respond_to?(:pointer_descr))
						@model.pointer_descr
					elsif(@model.respond_to?(:name))
						@model.name
					end
				else
					@lookandfeel.lookup(event)
				end
			end
			def topfoot(model, session)
				if(@lookandfeel.enabled?(:just_medical_structure, false))
					just_medical(model, session)
				elsif(@lookandfeel.enabled?(:oekk_structure, false))
					oekk_head(model)
				else
					TopFoot.new(model, session, self)
				end
			end
		end
	end
end
