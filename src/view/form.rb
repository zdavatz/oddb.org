#!/usr/bin/env ruby
# View::Form -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/form'
require 'htmlgrid/formlist'
require 'htmlgrid/inputtext'

module ODDB 
	module View
		module HiddenPointer
			private
			def hidden_fields(context)
				hidden = super
				hidden << context.hidden('pointer', @model.pointer.to_s) if @model.respond_to?(:pointer)
				hidden
			end
		end
		class Form < HtmlGrid::Form
			include View::HiddenPointer
			DEFAULT_CLASS = HtmlGrid::InputText
			EVENT = :update
			private 
			def delete_item(model, session)
				unless(@model.is_a? Persistence::CreateItem)
					button = HtmlGrid::Button.new(:delete, model, session, self)
					button.set_attribute("onclick", "form.event.value='delete'; form.submit();")
					button
				end
			end
			def post_event_button(event)
				button = HtmlGrid::Button.new(event, @model, @session, self)
				script = "this.form.event.value='"+event.to_s+"'; this.form.submit();"
				button.set_attribute("onclick", script)
				button
			end
			def get_event_button(event, params={})
				button = HtmlGrid::Button.new(event, @model, @session, self)
				url = @lookandfeel.event_url(event, params) 
				script = "document.location.href='#{url}';"
				button.set_attribute("onclick", script)
				button
			end
		end
		class FormList < HtmlGrid::FormList
			include View::HiddenPointer
		end
	end
end
