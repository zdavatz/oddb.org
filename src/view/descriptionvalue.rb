#!/usr/bin/env ruby
# View::DescriptionValue -- oddb -- 28.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/value'

module ODDB
	module View
		class DescriptionValue < HtmlGrid::Value
			def init
				super
				@value = @value.description(@lookandfeel.language) if @value.respond_to?(:description)
			end
		end
	end
end
