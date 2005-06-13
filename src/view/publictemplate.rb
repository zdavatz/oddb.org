#!/usr/bin/env ruby
# View::PublicTemplate -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

puts "publictemplate"

puts "going to get htmlgrid/template"
require 'htmlgrid/template'
puts "going to get view/logohead"
require 'view/logohead'
puts "going to get view/navigationfoot"
require 'view/navigationfoot'
puts "going to get sbsm/time"
require 'sbsm/time'

puts "defining publictemplate"

module ODDB
	module View
		class PublicTemplate < HtmlGrid::Template
			CONTENT = nil
			CSS_CLASS = "composite"
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
					"http-equiv"	=>	"robots",
					"content"			=>	"follow, index",
				},
			]
			def content(model, session)
				self::class::CONTENT.new(model, session, self)
			end
			def head(model, session)
				self::class::HEAD.new(model, session, self)
			end
			def foot(model, session)
				self::class::FOOT.new(model, session, self) unless self::class::FOOT.nil?
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
					if(@model.respond_to?(:name))
						@model.name
					elsif(@model.respond_to?(:pointer_descr))
						@model.pointer_descr
					end
				else
					@lookandfeel.lookup(event)
				end
			end
		end
	end
end

puts "defined publictemplate"
