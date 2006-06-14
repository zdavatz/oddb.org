#!/usr/bin/env ruby
# View::Drugs::LimitationText -- oddb -- 12.11.2003 -- mhuggler@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/chapter'
require 'util/pointerarray'

module ODDB
	module View
		module Drugs
class LimitationTextInnerComposite < HtmlGrid::Composite
	COMPONENTS = {}
	DEFAULT_CLASS = View::Chapter
	def init
		yy = 0
		lang = @session.language.intern
		if(@model.respond_to?(lang) && @model.send(lang))
			components.store([0,yy], lang)
			yy += 1
		end
		super
	end			
end
class LimitationTextComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:limitation_text_title,
		[0,1]	=>	View::Drugs::LimitationTextInnerComposite,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0] => 'th',
		[0,1] => 'list',
	}	
	def limitation_text_title(model, session)
		if(sl_entry =  model.pointer.parent)
			parent = sl_entry.parent.resolve(session.app)
			@lookandfeel.lookup(:limitation_text_title, 
				parent.name_base)
		end
	end
end
class LimitationText < PrivateTemplate
	CONTENT = View::Drugs::LimitationTextComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
