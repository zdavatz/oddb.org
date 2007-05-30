#!/usr/bin/env ruby
# Notify -- oddb -- 08.04.2005 -- usenguel@ywesee.com, jlang@ywesee.com

require 'view/publictemplate'
require 'view/searchbar'
require 'view/notify_confirm'
require 'htmlgrid/form'
require 'htmlgrid/inputradio'
require 'htmlgrid/textarea'

module ODDB
	module View
		module Drugs
class NotifyConfirmComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	  =>	View::SearchForm,
		[0,1]	  =>	:notify_title,
		[0,2]	  =>	View::NotifySent,
	}
	CSS_MAP = {
		[0,1] => 'th',
	}	
	def notify_title(model, session)
		[@lookandfeel.lookup(:notify_title), model.item.name].join
	end
end
class NotifyConfirm < View::ResultTemplate
	CONTENT = View::Drugs::NotifyConfirmComposite
	EVENT = :result
end
		end
	end
end
