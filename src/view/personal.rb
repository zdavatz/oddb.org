#!/usr/bin/env ruby
# -- oddb -- 24.05.2005 -- jlang@ywesee.com, usenguel@ywesee.com

module ODDB
	module View
		module Personal
			def welcome(model, session)
				user = session.user
				div = HtmlGrid::Div.new(model, session, self)
				div.css_class = 'personal'
			  if(user.is_a? ODDB::CompanyUser)
					div.value = "#{@lookandfeel.lookup(:welcome)} #{user.model.contact} !"
					div
				elsif(user.is_a? ODDB::User)
					div.value = "#{@lookandfeel.lookup(:welcome)} #{user.unique_email} !"
					div
				end
			end
		end
	end
end
