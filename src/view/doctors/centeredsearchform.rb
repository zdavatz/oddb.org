#!/usr/bin/env ruby
# View::Doctors::CenteredSearchForm -- oddb -- 17.09.2004 -- jlang@ywesee.com

require 'view/centeredsearchform'

module ODDB
	module View
		module Doctors
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
		[0,0,3]	=>	:divider,
		[0,0,4]	=>	:language_en,
		[0,0,5]	=>	:beta,
		[0,1]		=>	View::Doctors::CenteredSearchForm,
		[0,2]		=>	'doctors_search_explain', 
		#0,4]		=>	View::CenteredNavigation,
		[0,5]		=>	:doctor_count,
		[0,5,1]	=>	'doctor_count_text',
		[0,5,2]	=>	'comma_separator',
		[0,5,6]	=>	'database_last_updated_txt',
		[0,5,7]	=>	:database_last_updated,
		[0,6]		=>	:legal_note,
		[0,7]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,6]		=>	'ccomponent',
	}
	COMPONENT_CSS_MAP = {
		[0,6]	=>	'legal-note-center',
	}
	def doctor_count(model, session)
		@session.doctor_count
	end
end	
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
	CONTENT = CenteredSearchComposite
	GOOGLE_CHANNEL = '1634362463'
end
		end
	end
end
