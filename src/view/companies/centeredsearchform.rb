#!/usr/bin/env ruby
# View::Companies::CenteredSearchForm -- oddb -- 07.09.2004 -- maege@ywesee.com

require 'view/centeredsearchform'

module ODDB
	module View
		module Companies
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
		[0,1]		=>	View::Companies::CenteredSearchForm,
		[0,2]		=>	'companies_search_explain', 
		[0,3]		=>	View::CenteredNavigation,
		[0,4]		=>	:company_count,
		[0,4,1]	=>	'company_count_text',
		[0,4,2]	=>	'comma_separator',
		[0,4,3]	=>	'database_last_updated_txt',
		[0,4,4]	=>	:database_last_updated,
		[0,5]		=>	View::LegalNoteLink,
		[0,6]		=>	:paypal,
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
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
	CONTENT = CenteredSearchComposite
	GOOGLE_CHANNEL = '7502058606'
end
		end
	end
end
