#!/usr/bin/env ruby
# View::Drugs::CenteredSearchForm -- oddb -- 07.09.2004 -- maege@ywesee.com

require 'view/centeredsearchform'
require 'view/google_ad_sense'

module ODDB
	module View
		module Drugs
class CenteredSearchForm < View::CenteredSearchForm
	COMPONENTS = {
		[0,0]		=>	View::TabNavigation,
		[0,1,0,1]	=>	:search_query,
		[0,2,0,2]	=>	:submit,
		[0,2,0,3]	=>	:search_reset,
		[0,2,0,4]	=>	:search_help,
	}
	EVENT = :search
end
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = {
		[0,0]		=>	:language_de,
		[0,0,1]	=>	:divider,
		[0,0,2]	=>	:language_fr,
		[0,0,3]	=>	:beta,
		[0,1]		=>	View::Drugs::CenteredSearchForm,
		[0,2]		=>	:search_explain, 
		[0,3]		=>	:search_compare,
		[0,4]		=>	View::CenteredNavigation,
		[0,5]		=>	:database_size,
		[0,5,1]	=>	'database_size_text',
		[0,5,2]	=>	'comma_separator',
		[0,6]		=>	:fachinfo_size,
		[0,6,1]	=>	'fi_count_text',
		[0,6,2]	=>	'comma_separator',
		[0,6,3] =>	:patinfo_size,
		[0,6,4] =>	'pi_count_text',
		[0,7]		=>	:atc_ddd_size,
		[0,7,1]	=>	:ddd_count_text,
		[0,7,2]	=>	'comma_separator',
		[0,7,3]	=>	:limitation_size,
		[0,7,4]	=>	:sl_count_text,
		[0,8] =>	'database_last_updated_txt',
		[0,8,1]	=>	:database_last_updated,
		[0,9]		=>	View::LegalNoteLink,
		[0,10]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,9]		=>	'ccomponent',
	}
	COMPONENT_CSS_MAP = {
		[0,9]	=>	'legal-note-center',
	}
	def ddd_count_text(model, session)
		link = HtmlGrid::Link.new(:ddd_count_text, model, session, self)
		link.href = 'http://www.whocc.no/atcddd/'
		link.set_attribute('class', 'list-b')
		link.target = '_blank'
		link
	end
	def sl_count_text(model, session)
		link = HtmlGrid::Link.new(:sl_count_text, model, session, self)
		link.href = 'http://www.galinfo.net'
		link.set_attribute('class', 'list-b')
		link.target = '_blank'
		link
	end
	def substance_count(model, session)
		@session.app.substance_count
	end
end	
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
	CONTENT = CenteredSearchComposite
	GOOGLE_CHANNEL = '2298340258'
end
		end
	end
end
