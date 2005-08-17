#!/usr/bin/env ruby
# SuggestAddressConfirm -- oddb -- 08.08.2005 -- jlang@ywesee.com

require 'view/address'
require 'view/privatetemplate'

module ODDB
	module View
class AddressSent < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	  =>	:address_sent,
		[1,0]	  =>  :go_back,
		[0,1]		=>	SuggestedAddress,
	}
	CSS_MAP = {
		[0,0,2] => 'confirm',
		[0,1] => 'list',
	}	
	def address_sent(model, session)
		@lookandfeel.lookup(:address_sent)
	end
	def go_back(model, session)
		link = HtmlGrid::Link.new(:address_back, model, session, self)
		link.href = @session.lookandfeel._event_url(:resolve,
			{:pointer => model.address_pointer.parent})
		link.css_class = 'list'
		link
	end
end
class AddressConfirmComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]		=>	'suggest_addr_title',
		[0,0,1]	=>	:fullname,
		[0,1]	  =>	AddressSent,
	}
	CSS_MAP = {
		[0,0] => 'th',
	}	
	DEFAULT_CLASS = HtmlGrid::Value
end
class AddressConfirm < PrivateTemplate
	CONTENT = View::AddressConfirmComposite
	SNAPBACK_EVENT = :result
end
	end
end
