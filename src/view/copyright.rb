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
			#HTML_ATTRIBUTES = {"align"=>"left"}
			LEGACY_INTERFACE = false
=begin
			def cpr_date(model, session)
				HtmlGrid::DateValue.new(:last_update, session.app, session, self)
			end
=end
			def oddb_version(model)
				link = standard_link(:oddb_version, model)
				link.href = 'http://scm.ywesee.com/?p=oddb.org;a=summary'
				link.set_attribute('title', ODDB_VERSION)
				link
			end
			def cpr_link(model)
				link = standard_link(:cpr_link, model)
				link.href = 'http://www.ywesee.com'
				link
			end
			def lgpl_license(model)
				link = standard_link(:lgpl_license, model)
				link.href = 'http://www.gnu.org/copyleft/lesser.html'
				link
			end
			def current_year(model)
				Time.now.year.to_s
			end
			def standard_link(key, model)
				klass = if(@lookandfeel.enabled?(:just_medical_structure, false))
					HtmlGrid::PopupLink
				else
					HtmlGrid::Link
				end
				link = klass.new(key, model, @session, self)
				link.css_class = 'navigation'
				link
			end
		end
	end
end
