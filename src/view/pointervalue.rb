#!/usr/bin/env ruby
# View::PointerValue -- oddb -- 11.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/value'
require 'cgi'

module ODDB
	module View
		class PointerValue < HtmlGrid::Value
			CSS_CLASS = 'list'
			def init
				method = @model.method(@name)
				args = (method.arity == 1) ? [@lookandfeel.language] : []
				value = @model.send(@name, *args)
				if(value.is_a? Symbol)
					@value = @lookandfeel.lookup(value)
				else
					@value = value
				end
			end
		end
		class PointerLink < View::PointerValue
			def to_html(context)
				arguments = {'pointer'	=>	CGI.escape(@model.pointer.to_s)}
				@attributes['href'] = @lookandfeel.event_url(:resolve, arguments)
				context.a(@attributes) { @value }
			end
		end
	end
end
