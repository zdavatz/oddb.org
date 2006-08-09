#!/usr/bin/env ruby
# View::User::CenteredSearchForm -- oddb -- 07.09.2004 -- mhuggler@ywesee.com

require 'view/centeredsearchform'
require	'view/language_chooser'

module ODDB
	module View
		module User
class CenteredSearchForm < View::CenteredSearchForm
	COMPONENTS = {
		[0,0]		=>	View::TabNavigation,
	}
	EVENT = :search
end
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = {
		[0,0]		=>	:language_chooser,
		[0,1]		=>	View::User::CenteredSearchForm,
		[0,4]		=>	View::CenteredNavigation,
		[0,5,0]	 =>	:fipi_offer,
		[0,5,1]	=>	:divider,
		[0,5,2]	=>	:new_registration,
		[0,6,0]	=>	:database_size,
		[0,6,1]	=>	'database_size_text',
		[0,6,2]	=>	'comma_separator',
		[0,6,3]	=>	'database_last_updated_txt',
		[0,6,4]	=>	:database_last_updated,
		[0,7]		=>	:generic_definition,
		[0,8]		=>	:legal_note,
		[0,9]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,9]		=>	'ccomponent',
	}
	COMPONENT_CSS_MAP = {
		[0,8]	=>	'legal-note-center',
	}
	def new_registration(model, session)
		link = HtmlGrid::Link.new(:new_registration, model, @session, self)
		link.href = @lookandfeel._event_url(:new_registration)
		link
	end
	def substance_count(model, session)
		@session.app.substance_count
	end
end	
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
	CONTENT = CenteredSearchComposite
	GOOGLE_CHANNEL = '4606893552'
end
		end
	end
end
