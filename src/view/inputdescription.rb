#!/usr/bin/env ruby
# encoding: utf-8
# View::InputDescription -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'htmlgrid/inputtext'

module ODDB
	module View
		class InputDescription < HtmlGrid::InputText
			def init
				super
				lang = @session.language
				self.value = @model.send(lang) if(@model.respond_to?(lang))
			end
		end
	end
end
