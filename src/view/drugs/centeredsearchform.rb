#!/usr/bin/env ruby
# View::Drugs::CenteredSearchForm -- oddb -- 07.09.2004 -- mhuggler@ywesee.com

require 'htmlgrid/select'
require 'view/centeredsearchform'
require 'view/google_ad_sense'

module ODDB
	module View
		module Drugs
class CenteredSearchForm < View::CenteredSearchForm
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]			=>	View::TabNavigation,
		[0,1]			=>	'search_type',
		[0,2,0,1]	=>	:search_type,
		[0,3,0,2]	=>	:search_query,
		[0,4,0,3]	=>	:submit,
		[0,4,0,4]	=>	:search_reset,
	}
	SYMBOL_MAP = {
		:search_type	=>	HtmlGrid::Select,
		:search_query	=>	View::SearchBar,	
	}
	COMPONENT_CSS_MAP = {
		[0,0]		=>	'component tabnavigation center',
	}
	CSS_MAP = {
		[0,1]	=>	'ccomponent', ## gives a nice padding
		[0,2,1,3]	=>	'search-center',
	}
	EVENT = :search
end
class CenteredSearchComposite < View::CenteredSearchComposite
	COMPONENTS = {
		[0,0]		=>	:language_chooser,
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
		[0,8]		=>	:generic_definition,
		[0,9]		=>	:legal_note,
		[0,10]		=>	:paypal,
	}
	CSS_MAP = {
		[0,0,1,10]		=>	'ccomponent',
	}
	COMPONENT_CSS_MAP = {
		[0,9]	=>	'legal-note-center',
	}
	def init
		if(@lookandfeel.enabled?(:just_medical_structure, false))
			@components = {
				[0,0]		=>	:language_chooser,
				[0,1]		=>	View::Drugs::CenteredSearchForm,
				[0,2]		=>	'search_explain', 
			}
		end
		super
	end
	def ddd_count_text(model, session)
		create_link(:ddd_count_text, 'http://www.whocc.no/atcddd/')
	end
	def sl_count_text(model, session)
		create_link(:sl_count_text, 
			'http://www.galinfo.net',
			:limitation_texts)
	end
	def fi_count_text(model, session)
		create_link(:fi_count_text, 
			'http://wiki.oddb.org/wiki.php?pagename=ODDB.Fi-Upload',
			:fachinfos)
	end
	def pi_count_text(model, session)
		create_link(:pi_count_text, 
			'http://wiki.oddb.org/wiki.php?pagename=ODDB.Pi-Upload', 
			:patinfos)
	end
	def create_link(text_key, href, event=nil)
		link = HtmlGrid::Link.new(text_key, @model, @session, self)
		if(event && @lookandfeel.enabled?(event))
			link.href = @lookandfeel._event_url(event)
		else
			link.href = href
		end
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
