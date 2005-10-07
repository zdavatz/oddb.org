#!/usr/bin/env ruby
#  -- oddb -- 05.10.2005 -- ffricker@ywesee.com

require 'view/drugs/limitationtext'
require 'view/popuptemplate'
require 'view/privatetemplate'


module ODDB
	module View
		module Migel
class LimitationTextInnerComposite < View::Drugs::LimitationTextInnerComposite
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
class LimitationTextComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:limitation_text_title,
		[0,1]	=>	View::Migel::LimitationTextInnerComposite,
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
class LimitationText < View::PrivateTemplate
	CONTENT = View::Migel::LimitationTextComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
