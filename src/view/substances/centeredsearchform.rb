#!/usr/bin/env ruby
# View::Substances::CenteredSearchForm -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'view/centeredsearchform'

module ODDB
	module View
		module Substances
class CenteredSearchForm < View::CenteredSearchForm
	COMPONENTS = {
		[0,0]		=>	View::TabNavigation,
		[0,1]		=>	:search_query,
		[0,2]		=>	:submit,
		[0,2,1]	=>	:search_reset,
		[0,2,2]	=>	:search_help,
	}
	EVENT = :search
end
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = { 
		[0,0]		=>	:language_de,
		[0,0,1]	=>	:divider,
		[0,0,2]	=>	:language_fr,
		[0,0,3]	=>	:beta,
		[0,1]		=>	View::Substances::CenteredSearchForm,
		[0,2]		=>	'substance_search_explain', 
		[0,3,3]	=>	:substance_count,
		[0,3,4]	=>	'substance_count_text',
		[0,3,5]	=>	'comma_separator',
		[0,3,6]	=>	'database_last_updated_txt',
		[0,3,7]	=>	:database_last_updated,
		[0,4]		=>	View::LegalNoteLink,
		[0,5]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,4]		=>	'ccomponent',
	}
	COMPONENT_CSS_MAP = {
		[0,4]	=>	'legal-note-center',
	}
	def substance_count(model, session)
		@session.app.substance_count
	end
end
		end
	end
end
