#!/usr/bin/env ruby
# AddedToInteractionView -- oddb -- 04.06.2004 -- maege@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/datevalue'
require 'htmlgrid/list'
require 'view/popuptemplate'
require 'view/resultcolors'
require 'view/resultfoot'
require 'view/dataformat'

module ODDB
	class AddedToInteractionComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	:name,
			[0,2]	=>	'added_to_interaction',
			[0,4]	=>	:close_window,
		}
		CSS_CLASS = 'composite'
		def close_window(model, session)
			link = HtmlGrid::Link.new(:close_window, model, session, self)
			link.href = @lookandfeel.lookup(:close_window_href)
			link.value = @lookandfeel.lookup(:close_window)
			link
		end
		def name(model, session)
			nil
		end
	end
	class AddedToInteractionView < PopupTemplate
		CONTENT = AddedToInteractionComposite
	end
end
