#!/usr/bin/env ruby
# View::Notify -- oddb -- 24.10.2005 -- ffricker@ywesee.com

require 'view/notify'

module ODDB
	module View
module Migel
		class NotifyComposite < HtmlGrid::Composite
			CSS_CLASS = 'composite'
			COMPONENTS = {
				[1,0]	  =>	View::SearchForm,
				[0,1]	  =>	:notify_migel_title,
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
			def notify_migel_title(model, session)
				[@lookandfeel.lookup(:notify_migel_title), model.item.name].join
			end
		end
		class Notify < View::ResultTemplate
			CONTENT = NotifyComposite
		end
end
	end
end

