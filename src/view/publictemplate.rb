#!/usr/bin/env ruby
# PublicTemplate -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/template'
require 'view/logohead'
require 'view/navigationfoot'
require 'sbsm/time'

module ODDB
	class PublicTemplate < HtmlGrid::Template
		CONTENT = nil
		CSS_CLASS = "composite"
		COMPONENTS = {
			[0,0]		=>	:head,
			[0,1]		=>	:content,
			[0,2]		=>	:foot,
		}
		HEAD = LogoHead
		HTTP_HEADERS = {
			"Content-Type"	=>	"text/html; charset=iso-8859-1",
			"Cache-Control"	=>	"private, no-store, no-cache, must-revalidate, post-check=0, pre-check=0",
			"Pragma"				=>	"no-cache",
			"Expires"				=>	Time.now.rfc1123,
			"P3P"						=>	"CP='OTI NID CUR OUR STP ONL UNI PRE'",
		}
		FOOT = NavigationFoot
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
	end
end
