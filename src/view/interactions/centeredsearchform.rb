#!/usr/bin/env ruby
# View::Interactions::CenteredSearchForm -- oddb -- 26.05.2004 -- mhuggler@ywesee.com

require 'view/centeredsearchform'
require 'view/language_chooser'

module ODDB
	module View
		module Interactions
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = { 
		[0,0]		=>	:language_chooser,
		[0,1]		=>	View::CenteredSearchForm,
		[0,2]		=>	'interaction_search_explain1', 
		[0,3]		=>	'interaction_search_explain2', 
		[0,4]		=>	'interaction_search_explain3', 
		[0,6]		=>	View::CenteredNavigation,
		[0,7,0]	=>	:database_size,
		[0,7,1]	=>	'database_size_text',
		[0,7,2]	=>	'comma_separator',
		[0,7,3]	=>	:substance_count,
		[0,7,4]	=>	'substance_count_text',
		[0,7,5]	=>	'comma_separator',
		[0,7,6]	=>	'database_last_updated_txt',
		[0,7,7]	=>	:database_last_updated,
		[0,8]		=>	:legal_note,
		[0,9]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,10]		=>	'list center',
	}
	COMPONENT_CSS_MAP = {
		[0,8]	=>	'legal-note',
	}
	def substance_count(model, session)
		@session.app.substance_count.to_s << '&nbsp;'
	end
end	
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
	CONTENT = CenteredSearchComposite
	GOOGLE_CHANNEL = '6290728057'
end
		end
	end
end
