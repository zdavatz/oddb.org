#!/usr/bin/env ruby
# View::Drugs::CenteredSearchForm -- oddb -- 07.09.2004 -- maege@ywesee.com

require 'htmlgrid/inputcheckbox'
require 'view/centeredsearchform'
require 'view/google_ad_sense'

module ODDB
	module View
		module Drugs
class CenteredSearchForm < View::CenteredSearchForm
	COMPONENTS = {
		[0,0]		=>	View::TabNavigation,
		[0,1,0,1]	=>	:search_query,
		[0,2,0,2]	=>	:exact_match,
		[0,2,1]		=>	'exact_match',
		[0,3,0,3]	=>	:submit,
		[0,3,0,4]	=>	:search_reset,
		[0,3,0,5]	=>	:search_help,
	}
	SYMBOL_MAP = {
		:exact_match	=>	HtmlGrid::InputCheckbox,
		:search_query	=>	View::SearchBar,	
	}
	EVENT = :search
end
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = {
		[0,0]		=>	:language_de,
		[0,0,1]	=>	:divider,
		[0,0,2]	=>	:language_fr,
		[0,0,3]	=>	:beta,
		[0,0,4]	=>	:divider,
		[0,0,5]	=>	:language_en,
		[0,0,6]	=>	:beta,
		[0,1]		=>	View::Drugs::CenteredSearchForm,
		[0,2]		=>	:search_explain, 
		[0,3]		=>	View::CenteredNavigation,
		[0,4]		=>	:database_size,
		[0,4,1]	=>	'database_size_text',
		[0,4,2]	=>	'comma_separator',
		[0,5]		=>	:fachinfo_size,
		[0,5,1]	=>	:fi_count_text,
		[0,5,2]	=>	'comma_separator',
		[0,5,3] =>	:patinfo_size,
		[0,5,4] =>	:pi_count_text,
		[0,6]		=>	:atc_ddd_size,
		[0,6,1]	=>	:ddd_count_text,
		[0,6,2]	=>	'comma_separator',
		[0,6,3]	=>	:limitation_size,
		[0,6,4]	=>	:sl_count_text,
		[0,7] =>	'database_last_updated_txt',
		[0,7,1]	=>	:database_last_updated,
		[0,8]		=>	View::LegalNoteLink,
		[0,9]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,8]		=>	'ccomponent',
	}
	COMPONENT_CSS_MAP = {
		[0,8]	=>	'legal-note-center',
	}
	def ddd_count_text(model, session)
		create_link(:ddd_count_text, 'http://www.whocc.no/atcddd/')
	end
	def sl_count_text(model, session)
		create_link(:sl_count_text, 'http://www.galinfo.net')
	end
	def fi_count_text(model, session)
		create_link(:fi_count_text, 'http://wiki.oddb.org/wiki.php?pagename=Swissmedic.Interpellation')
	end
	def pi_count_text(model, session)
		create_link(:pi_count_text, 'http://wiki.oddb.org/wiki.php?pagename=Swissmedic.Interpellation')
	end
	def create_link(text_key, href)
		link = HtmlGrid::Link.new(text_key, @model, @session, self)
		link.href = href
		link.set_attribute('class', 'list')
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
