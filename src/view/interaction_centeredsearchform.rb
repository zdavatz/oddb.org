#!/usr/bin/env ruby
# InteractionCenteredSearchForm -- oddb -- 26.05.2004 -- maege@ywesee.com

require 'view/centeredsearchform'

module ODDB
	class InteractionCenteredSearchForm < CenteredSearchForm
		COMPONENTS = {
			[0,0]		=>	:search_query,
			[0,1]		=>	:submit,
			[0,1,1]	=>	:search_reset,
			[0,1,2]	=>	:search_help,
		}
		EVENT = :search_interaction
	end
	class InteractionCenteredSearchComposite < CenteredSearchComposite
		COMPONENTS = { 
			[0,0]		=>	:language_de,
			[0,0,1]	=>	:divider,
			[0,0,2]	=>	:language_fr,
			[0,0,3]	=>	:beta,
			[0,1]		=>	'interaction_search_explain', 
			[0,2]		=>	InteractionCenteredSearchForm,
			[0,3]		=>	:database_size,
			[0,3,1]	=>	'database_size_text',
			[0,3,2]	=>	'comma_separator',
			[0,3,3]	=>	:substance_count,
			[0,3,4]	=>	'substance_count_text',
			[0,3,5]	=>	'comma_separator',
			[0,3,6]	=>	'database_last_updated_txt',
			[0,3,7]	=>	:database_last_updated,
			[0,4]		=>	:paypal,
		}
		def substance_count(model, session)
			@session.app.substance_count
		end
	end	
end
