#!/usr/bin/env ruby
# View::User::CenteredSearchForm -- oddb -- 07.09.2004 -- maege@ywesee.com

require 'view/centeredsearchform'

module ODDB
	module View
		module User
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
		[0,1]		=>	View::User::CenteredSearchForm,
		#[0,2]		=>	:search_explain, 
		#[0,3]		=>	:search_compare,
		[0,4]		=>	:software_feedback,
		[0,4,1]	=>	:divider,
		[0,4,2]	=>	:fipi_offer,
		[0,5]		=>	:database_size,
		[0,5,1]	=>	'database_size_text',
		[0,5,2]	=>	'comma_separator',
		[0,5,3]	=>	'database_last_updated_txt',
		[0,5,4]	=>	:database_last_updated,
		[0,6]		=>	:generic_definition,
		[0,7]		=>	View::LegalNoteLink,
		[0,8]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,7]		=>	'ccomponent',
	}
	COMPONENT_CSS_MAP = {
		[0,7]	=>	'legal-note-center',
	}
	def substance_count(model, session)
		@session.app.substance_count
	end
end	
		end
	end
end
