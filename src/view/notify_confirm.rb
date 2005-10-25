#!/usr/bin/env ruby
#  -- oddb -- 24.10.2005 -- ffricker@ywesee.com


require 'view/publictemplate'
require 'view/searchbar'
require 'htmlgrid/form'
require 'htmlgrid/inputradio'
require 'htmlgrid/textarea'

module ODDB
	module View
class NotifySent < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	  =>	:notify_sent,
		[1,0]	  =>  :go_back,
	}
	CSS_MAP = {
		[0,0] => 'confirm',
		[1,0] => 'confirm',
	}	
	def notify_sent(model, session)
		[
			@lookandfeel.lookup(:notify_sent0),
			model.notify_recipient,
			@lookandfeel.lookup(:notify_sent1),
		].join
	end
	def go_back(model, session)
	link = HtmlGrid::Link.new(:notify_back, model, session, self)
		link.href = @session.lookandfeel._event_url(:result)
		link.css_class = 'list'
		link
	end
end
	end
end
