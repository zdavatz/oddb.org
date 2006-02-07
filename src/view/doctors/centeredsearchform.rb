#!/usr/bin/env ruby
# View::Doctors::CenteredSearchForm -- oddb -- 17.09.2004 -- jlang@ywesee.com

require 'view/centeredsearchform'
require	'view/language_chooser'

module ODDB
	module View
		module Doctors
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = { 
		[0,0]		=>	:language_chooser,
		[0,1]		=>	View::CenteredSearchForm,
		[0,2]		=>	'doctors_search_explain', 
		[0,3]		=>	View::CenteredNavigation,
		[0,4]		=>	'download_doctors0',
		[0,4,1]	=>	:download_doctors,
		[0,4,2]	=>	'download_doctors2',
		[0,5]		=>	:doctor_count,
		[0,5,1]	=>	'doctor_count_text',
		[0,5,2]	=>	'comma_separator',
		[0,5,6]	=>	'database_last_updated_txt',
		[0,5,7]	=>	:database_last_updated,
		[0,6]		=>	:legal_note,
		[0,7]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,7]		=>	'ccomponent',
	}
	COMPONENT_CSS_MAP = { }
	def doctor_count(model, session)
		@session.doctor_count.to_s << '&nbsp;'
	end
	def download_doctors(model, session)
		link = HtmlGrid::Link.new(:download_doctors1, model, session, self)
		link.href = @lookandfeel._event_url(:download_export)
		link
	end
end	
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
	CONTENT = CenteredSearchComposite
	GOOGLE_CHANNEL = '1634362463'
end
		end
	end
end
