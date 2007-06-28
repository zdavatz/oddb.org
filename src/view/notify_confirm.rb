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
class NotifyConfirmComposite < HtmlGrid::Composite
  include NotifyTitle
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	  =>	View::SearchForm,
		[0,1]	  =>	:notify_title,
		[0,2]	  =>	:notify_sent,
	}
	CSS_MAP = {
		[0,1] => 'th',
		[0,2] => 'confirm',
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
end
class NotifyConfirm < View::ResultTemplate
	CONTENT = NotifyConfirmComposite
  def http_headers
    headers = super
		url = @session.lookandfeel._event_url(:result)
    headers.store('Refresh', "5; URL=#{url}")
    headers
  end
end
	end
end
