#!/usr/bin/env ruby
#  -- oddb -- 24.10.2005 -- ffricker@ywesee.com

require 'view/notify'
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
		[1,0] => 'confirm right',
	}	
	def notify_sent(model, session)
    last, *mails = model.notify_recipient.reverse
    string = if(mails.empty?) 
               last
             else
               [mails.reverse.join(', '), last].join(@lookandfeel.lookup(:and))
             end
    @lookandfeel.lookup(:notify_sent, string)
	end
	def go_back(model, session)
	link = HtmlGrid::Link.new(:notify_back, model, session, self)
		link.href = @session.lookandfeel._event_url(:result)
		link.css_class = 'list'
		link
	end
end
class NotifyConfirmComposite < HtmlGrid::Composite
  include NotifyTitle
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	  =>	View::SearchForm,
		[0,1]	  =>	:notify_title,
		[0,2]	  =>	View::NotifySent,
	}
	CSS_MAP = {
		[0,1] => 'th',
	}	
end
class NotifyConfirm < View::ResultTemplate
	CONTENT = NotifyConfirmComposite
end
	end
end
