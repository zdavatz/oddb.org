#!/usr/bin/env ruby
# View::Copyright -- oddb -- 27.05.2003 -- mhuggler@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/link'
require 'htmlgrid/datevalue'

module ODDB
	module View
		class Copyright < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]			=>  :lgpl_license,
				[1,0]			=>  'comma_separator',
				[2,0]			=>  :current_year,
				[3,0]			=>	:cpr_link,
				[4,0]			=>	:oddb_version,
			}
			CSS_CLASS = "navigation"
			HTML_ATTRIBUTES = {"align"=>"left"}
			LEGACY_INTERFACE = false
=begin
			def cpr_date(model, session)
				HtmlGrid::DateValue.new(:last_update, session.app, session, self)
			end
=end
			def oddb_version(model)
				link = HtmlGrid::Link.new(:oddb_version, model, @session, self)
				link.href = 'http://ywesee.bkbits.net:8080/oddb.org'
				link.css_class = 'navigation'
				link
			end
			def cpr_link(model)
				link = HtmlGrid::Link.new(:cpr_link, model, @session, self)
				link.href = 'http://www.ywesee.com'
				link.css_class = 'navigation'
				link
			end
			def lgpl_license(model)
				link = HtmlGrid::Link.new(:lgpl_license, model, @session, self)
				link.href = 'http://www.gnu.org/copyleft/lesser.html'
				link.css_class = 'navigation'
				link
			end
			def current_year(model)
				Time.now.year.to_s
			end
		end
	end
end
