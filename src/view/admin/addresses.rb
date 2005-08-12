#!/usr/bin/env ruby
# View::Admin::Addresses -- oddb -- 09.08.2005 -- jlang@ywesee.com

require 'view/resulttemplate'
require 'view/suggest_address'
require 'view/pointervalue'

module ODDB
	module View
		module Admin
class AddressList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:time,
		[1,0]	=>	:parent_class,
		[2,0]	=>	:address_type,
		[3,0]	=>	:title,
		[4,0]	=>	:name,
		[5,0]	=>	:address,
		[6,0]	=>	:location,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = { 
		[0,0,7]	=>	'list'	
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'th'
	LEGACY_INTERFACE = false
	SORT_DEFAULT = :time
	SORT_REVERSE = true
	SYMBOL_MAP = {
		:name	=>	PointerLink,
	}
	def address_type(model)
		@lookandfeel.lookup(model.type)
	end
	def parent_class(model)
		ptr = model.address_pointer
		obj = ptr.parent.resolve(@session)
		@lookandfeel.lookup(obj.class)
	end
	def time(model)
		if(time = model.time)
			link = PointerLink.new(:time, model, @session,self)
			fmt = @lookandfeel.lookup(:time_format_long)
			link.value = time.strftime(fmt)
			link
		end
	end
end
class Addresses < ResultTemplate
	CONTENT = View::Admin::AddressList
end
		end
	end
end
