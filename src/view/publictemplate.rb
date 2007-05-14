#!/usr/bin/env ruby
# View::PublicTemplate -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/template'
require 'view/logohead'
require 'view/navigationfoot'
require 'sbsm/time'
require 'view/custom/head'
require 'view/htmlgrid/component'

module ODDB
	module View
		class PublicTemplate < HtmlGrid::Template
			include View::Custom::HeadMethods
			include HtmlGrid::DojoToolkit::DojoTemplate
			DOJO_DEBUG = false
      DOJO_REQUIRE = [ 'dojo.widget.Tooltip' ]
      DOJO_PARSE_WIDGETS = false
      DOJO_PREFIX = {
        'ywesee'  =>  '../javascript',
      }
			CONTENT = nil
			CSS_CLASS = "composite"
			#CSS_ID = "template"
			COMPONENTS = {
				[0,0]		=>	:head,
				[0,1]		=>	:content,
				[0,2]		=>	:foot,
			}
			HEAD = View::LogoHead
			HTTP_HEADERS = {
				"Content-Type"	=>	"text/html; charset=iso-8859-1",
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
			def content(model, session)
				self::class::CONTENT.new(model, session, self)
			end
			def css_link(context, path=nil)
				if(@lookandfeel.enabled?(:external_css, false))
					super(context, @lookandfeel.resource_external(:external_css))
				else
					super
				end
			end
      def dynamic_html_headers(context)
        if(@lookandfeel.enabled?(:ajax))
          super
        else
          ''
        end
      end
			def foot(model, session)
				self::class::FOOT.new(model, session, self) unless self::class::FOOT.nil?
			end
			def head(model, session)
				self::class::HEAD.new(model, session, self)
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
