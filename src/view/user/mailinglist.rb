#!/usr/bin/env ruby
# encoding: utf-8
# View::User::MailingList -- oddb -- 30.09.2003 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/form'
require	'htmlgrid/errormessage'
require	'htmlgrid/infomessage'

module ODDB
	module View
		module User
class MailingListForm < View::Form
	COMPONENTS = {
		[0,0]		=>	:email,
		[1,0]		=>	:subscribe,
		[2,0]		=>	:unsubscribe,
	}
	COMPONENT_CSS_MAP = {
		[0,0]	=>	'mailinglist',
	}
	LABELS = false
	SYMBOL_MAP = {
		:email	=>	HtmlGrid::InputText,
	}
	def subscribe(model, session)
		submit(model, session, :subscribe)
	end
	def unsubscribe(model, session)
		submit(model, session, :unsubscribe)
	end
end
class MailingListInnerComposite < HtmlGrid::Composite
	include HtmlGrid::ErrorMessage
	include HtmlGrid::InfoMessage
	COMPONENTS = {
		[0,0]		=>	'mailinglist_form_descr',
		[0,1]		=>	View::User::MailingListForm,
	}
	CSS_CLASS = 'list'
	def init
		super
		error_message()
		info_message()
	end
end
class MailingListComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	'mailinglist_title',
		[0,1]		=>	View::User::MailingListInnerComposite,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	def score(model, session)
		'&nbsp;-&nbsp;'
	end
end
class MailingList < View::PublicTemplate
	CONTENT = View::User::MailingListComposite 
end
		end
	end
end
