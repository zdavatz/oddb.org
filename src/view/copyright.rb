#!/usr/bin/env ruby
# View::Copyright -- oddb -- 27.05.2003 -- maege@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/link'
require 'htmlgrid/datevalue'

module ODDB
	module View
		class Copyright < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]			=>	:cpr_link,
				[0,0,0]		=>	:cpr_updated,
				[0,0,0,0]	=>	:cpr_date,
			}
			CSS_CLASS = "navigation"
			HTML_ATTRIBUTES = {"align"=>"left"}
			SYMBOL_MAP = {
				:cpr_updated	=>	HtmlGrid::Text,	
				:cpr_link			=>	HtmlGrid::Link,
			}
			def cpr_date(model, session)
				HtmlGrid::DateValue.new(:last_update, session.app, session, self)
			end
		end
	end
end
