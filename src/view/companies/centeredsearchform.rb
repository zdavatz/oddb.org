#!/usr/bin/env ruby
# View::Companies::CenteredSearchForm -- oddb -- 07.09.2004 -- maege@ywesee.com

require 'view/centeredsearchform'

module ODDB
	module View
		module Companies
class CenteredSearchForm < View::CenteredSearchForm
	COMPONENTS = {
		[0,0]		=>	View::TabNavigation,
		#[0,1]		=>	:search_query,
		#[0,2]		=>	:submit,
		#[0,2,1]	=>	:search_reset,
		#[0,2,2]	=>	:search_help,
	}
	EVENT = :search
end
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = {
		[0,0]		=>	:language_de,
		[0,0,1]	=>	:divider,
		[0,0,2]	=>	:language_fr,
		[0,0,3]	=>	:beta,
		[0,1]		=>	View::Companies::CenteredSearchForm,
		#[0,2]		=>	:search_explain, 
		#[0,3]		=>	:search_compare,
		[0,4]		=>	View::CenteredNavigation,
		[0,5]		=>	:company_count,
		[0,5,1]	=>	'company_count_text',
		[0,5,2]	=>	'comma_separator',
		[0,5,3]	=>	'database_last_updated_txt',
		[0,5,4]	=>	:database_last_updated,
		[0,6]		=>	View::LegalNoteLink,
		[0,7]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,6]		=>	'ccomponent',
	}
	COMPONENT_CSS_MAP = {
		[0,6]	=>	'legal-note-center',
	}
	def company_count(model, session)
		@session.app.company_count
	end
end	
		end
	end
end
