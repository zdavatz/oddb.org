#!/usr/bin/env ruby
# encoding: utf-8
# View::Admin::CenteredSearchForm -- oddb -- 07.09.2004 -- mhuggler@ywesee.com

require 'view/centeredsearchform'
require 'view/language_chooser'

module ODDB
	module View
		module Admin
class CenteredSearchForm < View::CenteredSearchForm
	COMPONENTS = {
		[0,0]		=>	View::TabNavigation,
	}
	COMPONENT_CSS_MAP = {
		[0,0]		=>	'component tabnavigation'
	}
	CSS_MAP = {
		[0,0]		=>	'center'
	}
	EVENT = :search
end
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = {
		[0,0]		=>	:language_chooser,
		[0,1]		=>	View::Admin::CenteredSearchForm,
		[0,3]		=>	View::CenteredNavigation,
		[0,4,0]	=>	:database_size,
		[0,4,1]	=>	'database_size_text',
		[0,4,2]	=>	'comma_separator',
		[0,4,3]	=>	'database_last_updated_txt',
		[0,4,4]	=>	:database_last_updated,
		[0,5]		=>	:legal_note,
		[0,6]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,7]		=>	'list center',
	}
	COMPONENT_CSS_MAP = {
		[0,5]	=>	'legal-note',
	}
	def substance_count(model, session)
		@session.app.substance_count
	end
end	
		end
	end
end
