#!/usr/bin/env ruby
# View::InputDescription -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'htmlgrid/inputtext'

module ODDB
	module View
		class InputDescription < HtmlGrid::InputText
			def init
				lang = @session.language
				@value = @model.send(lang) if(@model.respond_to?(lang))
				super
			end
		end
	end
end
