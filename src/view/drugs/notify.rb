#!/usr/bin/env ruby
# Notify -- oddb -- 21.03.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'view/notify'

module ODDB
	module View
module Drugs
		class NotifyComposite < HtmlGrid::Composite
		CSS_CLASS = 'composite'
		COMPONENTS = {
		[1,0]	  =>	View::SearchForm,
		[0,1]	  =>	:notify_title,
		[0,2]	  =>	NotifyForm,
		[1,1]	  =>	'notify_preview',
		[1,2]	  =>	:preview,
		}
		CSS_MAP = {
		[0,1] => 'th',
		[1,1] => 'th',
		}	
		def preview(model, session)
		unless model.empty?
			NotifyPreview.new(model, session, self)
		end
		end
		def notify_title(model, session)
		[@lookandfeel.lookup(:notify_title), model.item.name].join
		end
		end
		class Notify < View::ResultTemplate
		CONTENT = View::Drugs::NotifyComposite
		end
end
	end
end
