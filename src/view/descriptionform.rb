#!/usr/bin/env ruby
# DescriptionForm -- oddb -- 26.03.2003 -- aschrafl@ywesee.com

require 'view/form'
require 'view/exception'
require 'htmlgrid/submit'
require 'htmlgrid/button'
require 'htmlgrid/errormessage'

module ODDB
	class DescriptionForm < Form
		include HtmlGrid::ErrorMessage
		COMPONENTS = {}
		DELETE_BUTTON = true
		DEFAULT_CLASS = HtmlGrid::InputText
		DESCRIPTION_CSS = nil
		EVENT = :update
		LABELS = true
		def init
			index=0
			@lookandfeel.languages.each_with_index { |language, index|
				components.store([0,index], language.intern)
				if(descr_css = self::class::DESCRIPTION_CSS)
					component_css_map.store([1,index], descr_css)
				end
			}
			super
			@grid.add_style('list', 0, 0, 2, @grid.height)
			@grid.add(HtmlGrid::Submit.new(self::class::EVENT, @model, @session, self), 1, index.next)
			if(self::class::DELETE_BUTTON)
				button = HtmlGrid::Button.new(:delete, @model, @session, self)
				button.set_attribute("onclick", "form.event.value='delete'; form.submit();")
				@grid.add(button, 1, index.next)
			end
			error_message()
		end
	end
end
