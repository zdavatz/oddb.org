#!/usr/bin/env ruby
# LimitationTextView -- oddb -- 12.11.2003 -- maege@ywesee.com

require 'view/popuptemplate'
require 'view/chapter'
require 'util/pointerarray'

module ODDB
	class LimitationTextInnerComposite < HtmlGrid::Composite
		COMPONENTS = {}
		DEFAULT_CLASS = ChapterView
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
			[0,1]	=>	LimitationTextInnerComposite,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0] => 'th',
		}	
		def limitation_text_title(model, session)
			if(sl_entry =  model.pointer.parent)
				package = sl_entry.parent.resolve(session.app)
				@lookandfeel.lookup(:limitation_text_title, package.name_base)
			end
		end
	end
	class LimitationTextView < PopupTemplate
		CONTENT = LimitationTextComposite
	end
end
