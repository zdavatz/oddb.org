#!/usr/bin/env ruby
# View::NotifyConfirm -- oddb -- 24.10.2005 -- ffricker@ywesee.com

require 'view/notify_confirm'

module ODDB
	module View
		module Migel
class NotifyConfirmComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	  =>	View::SearchForm,
		[0,1]	  =>	:notify_migel_title,
		[0,2]	  =>	View::NotifySent,
	}
	CSS_MAP = {
		[0,1] => 'th',
	}	
	def notify_migel_title(model, session)
		[@lookandfeel.lookup(:notify_migel_title), model.item.name].join
	end
end
class NotifyConfirm < View::ResultTemplate
	CONTENT = NotifyConfirmComposite
	EVENT = :result
end
		end
	end
end
