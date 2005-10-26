#!/usr/bin/env ruby
# View::Drugs::LimitationText -- oddb -- 12.11.2003 -- mhuggler@ywesee.com

require 'view/popuptemplate'
require 'view/privatetemplate'
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
class LimitationText < View::PrivateTemplate
	CONTENT = View::Drugs::LimitationTextComposite
	SNAPBACK_EVENT = :result
end
class MigelLimitationTextInnerComposite < LimitationTextInnerComposite
	DEFAULT_CLASS = HtmlGrid::Value
	def subgroup(model, session)
		product = model.parent(@session.app)
		if(lim = product.subgroup.limitation_text)
			lim.send(@session.language)
		end
	end
	def group(model, session)
		product = model.parent(@session.app)
		if(lim = product.group.limitation_text)
			lim.send(@session.language)
		end
	end
end
class MigelLimitationTextComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:limitation_text_title,
		[0,1]	=>	View::Drugs::MigelLimitationTextInnerComposite,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0] => 'th',
		[0,1] => 'list',
	}	
	def limitation_text_title(model, session)
		if(pointer =  model.pointer.parent)
			parent = pointer.resolve(session.app)
			@lookandfeel.lookup(:limitation_text_title, 
				parent.send(@session.language))
		end
	end
end
class MigelLimitationText < View::PrivateTemplate
	CONTENT = View::Drugs::MigelLimitationTextComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
