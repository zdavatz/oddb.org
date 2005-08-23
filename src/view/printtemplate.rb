#!/usr/bin/env ruby
# View::PrintTemplate -- ODDB -- 09.03.2004 -- hwyss@ywesee.com

require 'view/popuptemplate'

module ODDB
	module View
		module Print
			def print(model, session)
				link = HtmlGrid::Link.new(:print, model, session, self)
				link.set_attribute('title', @lookandfeel.lookup(:print_title))
				args = { 
					:pointer	=> model.pointer,
				}
				link.href = @lookandfeel.event_url(:print, args)
				link
			end
		end
		class PrintTemplate < View::PopupTemplate
			def init
				@attributes['onload'] = 'window.print();'
				super
			end
			def head(model, session)
				@lookandfeel.lookup(:print_head)
			end
			def css_link(context)
				super(context, 
					@lookandfeel.resource_global(:css_print))
			end
		end
		module PrintComposite
			COLSPAN_MAP = {}
			COMPONENTS = {
				[0,0]	=>	:print_type,
				[0,1]	=>	:name,
				[0,2]	=>	:company_name,
				[0,3] =>	:document,
			}
			CSS_MAP = {
				[0,1] => 'print-big',
				[0,2]	=> 'list-r',
			}	
			def name(model, session)
				if(document = model.send(session.language))
					document.name
				end
			end
			def document(model, session)
				if(document = model.send(session.language))
					self::class::INNER_COMPOSITE.new(document, session, self)
				end
			end
			def print_type(model, session)
				@lookandfeel.lookup(self::class::PRINT_TYPE)
			end
		end
	end
end
