#!/usr/bin/env ruby
# ODDB::View::Personal -- oddb.org -- 01.07.2011 -- mahatakeyama@ywesee.com
# ODDB::View::Personal -- oddb.org -- 24.05.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'model/user'
require 'htmlgrid/div'

module ODDB
	module View
		module Personal
			def welcome(model, session)
				user = session.user
				div = HtmlGrid::Div.new(model, session, self)
				div.css_class = 'personal'
				if(user.is_a?(ODDB::YusUser))
          name = [user.name_first, user.name_last].compact.join(' ')
          if(name.strip.empty?)
            name = user.name
          end
          div.value = @lookandfeel.lookup(:welcome, name)
          div
				end
			end
		end
	end
end
