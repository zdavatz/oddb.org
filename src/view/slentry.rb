#!/usr/bin/env ruby
# SlEntryView -- oddb -- 22.04.2003 -- benfay@ywesee.com

require 'view/publictemplate'
require 'view/form'
require 'htmlgrid/inputdate'
require 'htmlgrid/select'
require 'htmlgrid/errormessage'

module ODDB
	class SlEntryInnerComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	:introduction_date,
			[0,1]	=>	:limitation,
			[1,1]	=>	:limitation_points,
		}
		CSS_MAP = {
			[0,0,4,2]	=>	'list',
		}
		LABELS = true
		SYMBOL_MAP = {
			:introduction_date => HtmlGrid::DateValue, 
		} 
	end
	class SlEntryForm < Form
		include HtmlGrid::ErrorMessage
		COMPONENTS = {
			[0,0]	=>	:introduction_date,
			[0,1]	=>	:limitation,
			[1,1]	=>	:limitation_points,
			[1,2]	=>	:submit,
			[1,2,0]=>	:delete_item,
		}
		COMPONENT_CSS_MAP = {
			[1,0]	=>	'standard',
		}
		CSS_MAP = {
			[0,0,4,3]	=>	'list',
		}
		LABELS = true
		SYMBOL_MAP = {
			:introduction_date => HtmlGrid::InputDate, 
			:limitation => HtmlGrid::Select,
		} 
		def init
			super
			error_message()
		end
		def limitation_points(model, session)
			input = HtmlGrid::InputText.new(:limitation_points, model, session, self)
			input.set_attribute('class', 'small' )
			input.label = false
			input
		end
	end
	class SlEntryComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	:package_name,
			[0,1]	=>	SlEntryInnerComposite,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th',
		}
		def package_name(model, session)
			package = model.parent(session.app)
			[
				package.name_base, 
				package.size, 
				@lookandfeel.lookup(:sl_entry),
			].compact.join('&nbsp;-&nbsp;')
		end
	end
	class RootSlEntryComposite < SlEntryComposite
		COMPONENTS = {
			[0,0]	=>	:package_name,
			[0,1]	=>	SlEntryForm,
		}
	end
	class SlEntryView < PrivateTemplate
		CONTENT = SlEntryComposite
		SNAPBACK_EVENT = :result
	end
	class RootSlEntryView < SlEntryView
		CONTENT = RootSlEntryComposite
	end
end
