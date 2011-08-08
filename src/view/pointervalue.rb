#!/usr/bin/env ruby
# ODDB::View::PointerValue -- oddb.org -- 08.08.2003 -- mhatakeyama@ywesee.com 
# ODDB::View::PointerValue -- oddb.org -- 11.03.2003 -- hwyss@ywesee.com 

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
        # @model.pointer.to_s might be like this:
        # :!registration,31706!sequence,01!package,017.
        # in such case, URL link will be smarter than the URL by using pointer.
        # z.B.) http://ch.oddb.org/de/gcc/drug/reg/31706/seq/01/pack/017
        # The old format is also available.
        smart_link_format = []
        if @model.pointer.respond_to?(:to_csv) and csv = @model.pointer.to_csv
          smart_link_format = csv.gsub(/registration/, 'reg').gsub(/sequence/, 'seq').gsub(/package/, 'pack').split(/,/)
        end
        if smart_link_format.include?('reg')
          @attributes['href'] = @lookandfeel._event_url(:drug, smart_link_format)
        else # This is an old format by using the default pointer format
          old_link_format = {'pointer'	=> @model.pointer.to_s}
				  @attributes['href'] = @lookandfeel._event_url(:resolve, old_link_format)
        end
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
