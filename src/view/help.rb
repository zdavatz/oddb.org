#!/usr/bin/env ruby
# HelpView -- oddb -- 21.08.2003 -- ywesee@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/link'
require 'view/popuptemplate'

module ODDB
	class HelpComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]		=>	:help_possibilities,
			[0,1]		=>	"help_namesearch",
			[0,2]		=>	:help_namesearch,
			[0,3]		=>	"help_agentsearch",
			[0,4]		=>	:help_agentsearch,
			[0,5]		=>	"help_compsearch",
			[0,6]		=>	:help_compsearch,
			[0,7]		=>	"help_atcsearch",
			[0,8]		=>	"help_atcsearch_txt",
			[0,9]		=>	"help_comparison",
			[0,10]	=>	"help_comparison_txt",
			[0,11]	=>	"help_sort",
			[0,12]	=>	"help_sort_txt",
			[0,13]	=>	"help_result_data",
			[0,14]	=>	"help_result_data_txt",
			[0,15]	=>	"companylist",
			[0,16]	=>	"help_companylist_txt",
			[0,17]	=>	"contact",
			[0,18]	=>	"contact_person",
			[0,19]	=>	"contact_email",
			[0,19,0]=>	:contact_email,
			[0,20]	=>	"contact_phone",
			[0,20,0]=>	:contact_phone,

		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th',
			[0,1]	=>	'section-title',
			[0,3]	=>	'section-title',
			[0,5]	=>	'section-title',
			[0,7]	=>	'section-title',
			[0,9]	=>	'section-title',
			[0,11]	=>	'section-title',
			[0,13]	=>	'section-title',
			[0,15]	=>	'section-title',
			[0,17]	=>	'section-title',
		}
		def contact_email(model, session)
			link = HtmlGrid::Link.new(:contact_email, model, session, self)
			link.href = 'mailto:zdavatz@ywesee.com'
			link.value = 'zdavatz at ywesee dot com'
			link
		end
		def contact_phone(model, session)
			'01 350 85 86'
		end
		def help_agentsearch(model, session)
			owner_text(:help_agentsearch)
		end
		def help_compsearch(model, session)
			owner_text(:help_compsearch)
		end
		def help_namesearch(model, session)
			owner_text(:help_namesearch)
		end
		def help_possibilities(model, session)
			owner_text(:help_possibilities)
		end
		def owner_text(key)
			@lookandfeel.lookup(key, 
				@lookandfeel.lookup(:lookandfeel_owner))
		end
	end
	class HelpView < PopupTemplate
		CONTENT = HelpComposite
	end
end
