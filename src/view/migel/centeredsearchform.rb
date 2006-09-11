#!/usr/bin/env ruby
#  -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'view/centeredsearchform'
require 'view/language_chooser'

module ODDB
	module View
		module Migel
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = { 
		[0,0]		=>	:language_chooser,
		[0,1]		=>	View::CenteredSearchForm,
		[0,2]		=>	'migel_search_explain', 
		[0,3]		=>	View::CenteredNavigation,
		[0,4,0]	=>	'download_migel0',
		[0,4,1]	=>	:download_migel,
		[0,4,2]	=>	'download_migel2',
		[0,5,0]	=>	:migel_count,
		[0,5,1]	=>	'migel_count_text',
		[0,5,2]	=>	'comma_separator',
		[0,5,6]	=>	'database_last_updated_txt',
		[0,5,7]	=>	:database_last_updated,
		[0,6]		=>	:legal_note,
		[0,7]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,8]		=>	'list center',
	}
	COMPONENT_CSS_MAP = { }
	def init
		if(@lookandfeel.enabled?(:just_medical_structure, false))
			@components = {
				[0,0]		=>	:language_chooser,
				[0,1]		=>	View::CenteredSearchForm,
				[0,2]		=>	'migel_search_explain', 
			}
			@css_map = { [0,0,1,3] => 'center' }
		elsif(@lookandfeel.enabled?(:atupri_web, false))
			@components = {
				[0,0]		=>	View::CenteredSearchForm,
				[0,1]		=>	'migel_search_explain', 
				[0,2,0]	=>	'download_migel0',
				[0,2,1]	=>	:download_migel,
				[0,2,2]	=>	'download_migel2',
				[0,3,0]	=>	:migel_count,
				[0,3,1]	=>	'migel_count_text',
				[0,3,2]	=>	'comma_separator',
				[0,3,6]	=>	'database_last_updated_txt',
				[0,3,7]	=>	:database_last_updated,
			}
			@css_map = { [0,0,1,4] => 'center' }
		end
		super
	end
	def migel_count(model, session)
		@session.migel_count.to_s << '&nbsp;'
	end
	def download_migel(model, session)
		link = HtmlGrid::Link.new(:download_migel1, model, session, self)
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
