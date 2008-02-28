#!/usr/bin/env ruby
# View::PointerValue -- oddb -- 11.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/value'
require 'cgi'

module ODDB
	module View
		class PointerValue < HtmlGrid::Value
			CSS_CLASS = 'list'
			def init
				value = @name
				if(@model.respond_to?(@name))
					method = @model.method(@name)
					args = (method.arity == 1) ? [@lookandfeel.language] : []
					value = @model.send(@name, *args)
				end
				if(value.is_a? Symbol)
					@value = @lookandfeel.lookup(value)
				else
					@value = value
				end
			end
		end
		class PointerLink < View::PointerValue
      def init
        super
				arguments = {'pointer'	=> @model.pointer.to_s}
				@attributes['href'] = @lookandfeel._event_url(:resolve, arguments)
      end
			def to_html(context)
				context.a(@attributes) { @value }
			end
      def href=(href)
        @attributes['href'] = href
      end
		end
	end
end
