#!/usr/bin/env ruby
# View::Personal -- oddb -- 24.05.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'model/user'

module ODDB
	module View
		module Personal
			def welcome(model, session)
				user = session.user
				div = HtmlGrid::Div.new(model, session, self)
				div.css_class = 'personal'
				case user
				when ODDB::CompanyUser, ODDB::AdminUser
					div.value = @lookandfeel.lookup(:welcome, user.model.contact)
					div
				when ODDB::User
					div.value = @lookandfeel.lookup(:welcome, user.unique_email)
					div
				end
			end
		end
	end
end
