#!/usr/bin/env ruby
# View::Interactions::CenteredSearchForm -- oddb -- 26.05.2004 -- maege@ywesee.com

require 'view/centeredsearchform'

module ODDB
	module View
		module Interactions
class CenteredSearchForm < View::CenteredSearchForm
	COMPONENTS = {
		[0,0]		=>	View::TabNavigation,
		[0,1]		=>	:search_query,
		[0,2]		=>	:submit,
		[0,2,1]	=>	:search_reset,
	}
	EVENT = :search
end
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = { 
		[0,0]		=>	:language_de,
		[0,0,1]	=>	:divider,
		[0,0,2]	=>	:language_fr,
		[0,0,3]	=>	:beta,
		[0,1]		=>	View::Interactions::CenteredSearchForm,
		[0,2]		=>	'interaction_search_explain', 
		[0,4]		=>	View::CenteredNavigation,
		[0,5]		=>	:database_size,
		[0,5,1]	=>	'database_size_text',
		[0,5,2]	=>	'comma_separator',
		[0,5,3]	=>	:substance_count,
		[0,5,4]	=>	'substance_count_text',
		[0,5,5]	=>	'comma_separator',
		[0,5,6]	=>	'database_last_updated_txt',
		[0,5,7]	=>	:database_last_updated,
		[0,6]		=>	View::LegalNoteLink,
		[0,7]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,6]		=>	'ccomponent',
	}
	COMPONENT_CSS_MAP = {
		[0,6]	=>	'legal-note-center',
	}
	def substance_count(model, session)
		@session.app.substance_count
	end
end	
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
	CONTENT = CenteredSearchComposite
	GOOGLE_CHANNEL = '6290728057'
end
		end
	end
end
