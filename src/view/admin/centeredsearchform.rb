#!/usr/bin/env ruby
# View::Admin::CenteredSearchForm -- oddb -- 07.09.2004 -- maege@ywesee.com

require 'view/centeredsearchform'
require 'view/language_chooser'

module ODDB
	module View
		module Admin
class CenteredSearchForm < View::CenteredSearchForm
	COMPONENTS = {
		[0,0]		=>	View::TabNavigation,
	}
	EVENT = :search
end
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = {
		[0,0]		=>	:language_chooser,
		[0,1]		=>	View::Admin::CenteredSearchForm,
		[0,3]		=>	:release_ouwerkerk,
		[0,4]		=>	View::CenteredNavigation,
		[0,5]		=>	:database_size,
		[0,5,1]	=>	'database_size_text',
		[0,5,2]	=>	'comma_separator',
		[0,5,3]	=>	'database_last_updated_txt',
		[0,5,4]	=>	:database_last_updated,
		[0,6]		=>	:legal_note,
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
	def release_ouwerkerk(model, session)
		if(@session.user.is_a?(RootUser))
			button = HtmlGrid::Button.new(:release_ouwerkerk, 
				model, session, self)
			url = @lookandfeel.event_url(:release)
			button.set_attribute('onclick', "window.location.href='#{url}'")
			button
		end
	end
end	
		end
	end
end
