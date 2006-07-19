#!/usr/bin/env ruby
# View::Analysis::CenteredSearchForm -- oddb.org -- 13.06.2006 -- sfrischknecht@ywesee.com

require 'view/centeredsearchform'
require 'view/language_chooser'

module ODDB
	module View
		module Analysis
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = {
		[0,0]		=>	:language_chooser,
		[0,1]		=>	View::CenteredSearchForm,
		[0,2]		=>	'analysis_search_explain',
		[0,3]		=>	:analysis_count,
		[0,3,1]	=>	'analysis_count',
		[0,4]		=>	View::CenteredNavigation,
	#	[0,4]		=>	'download_analysis0',
	#	[0,4,1]	=>	:download_analysis,
	#	[0,4,2]	=>	'download_analysis2',
	#	[0,5,1] =>	'database_last_updated_txt',
#		[0,5,2]	=>	:database_last_updated,
		[0,5]		=>	:legal_note,
		[0,6]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,7]	=>	'ccomponent',
	}
	COMPONENT_CSS_MAP = {}
	def download_analysis(model, session) 
		link = HtmlGrid::Link.new(:download_analysis1, model, session, self)
#		link.href = something
		link
	end
	def analysis_count(model, session)
		@session.analysis_count
	end
end
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
	CONTENT = CenteredSearchComposite
	GOOGLE_CHANNEL = '1634362463'
end
		end
	end
end
