#!/usr/bin/env ruby
# Notify -- oddb -- 08.04.2005 -- usenguel@ywesee.com, jlang@ywesee.com

require 'view/publictemplate'
require 'view/searchbar'
require 'htmlgrid/form'
require 'htmlgrid/inputradio'
require 'htmlgrid/textarea'

module ODDB
	module View
		module Drugs
class NotifySent < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	  =>	'notify_sent',
		[1,0]	  =>  :go_back,
	}
	CSS_MAP = {
		[0,0] => 'confirm',
		[1,0] => 'confirm',
	}	
	def go_back(model, session)
	link = HtmlGrid::Link.new(:notify_back, model, session, self)
		link.href = @session.lookandfeel._event_url(:result)
		link.css_class = 'list'
		link
	end
end
class NotifyConfirmComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	  =>	View::SearchForm,
		[0,1]	  =>	:notify_title,
		[0,2]	  =>	NotifySent,
	}
	CSS_MAP = {
		[0,1] => 'th',
	}	
	def notify_title(model, session)
		[@lookandfeel.lookup(:notify_title), model.package.name].join
	end
end
class NotifyConfirm < View::ResultTemplate
	CONTENT = View::Drugs::NotifyConfirmComposite
	EVENT = :result
end
		end
	end
end
