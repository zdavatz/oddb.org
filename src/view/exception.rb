#!/usr/bin/env ruby
# ExceptionView -- oddb -- 12.03.2003 -- andy@jetnet.ch

require 'view/publictemplate'
require 'htmlgrid/form'
require 'htmlgrid/text'
require 'view/searchbar'

module ODDB
	class ExceptionComposite < HtmlGrid::Form
		COMPONENTS = {
			[0,0]		=>	:search_query,
			[0,0,1]	=>	:submit,
			[0,1]		=>	:exception_header,
			[0,2]		=>	:exception,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'search',	
			[0,1]	=>	'th',
			[0,2]	=>	'error',
		}
		EVENT = :search
		SYMBOL_MAP = {
			:search_query			=>	SearchBar,	
			:exception_header	=>	HtmlGrid::Text,
		}
		def exception(model, session)
			HtmlGrid::Text.new(model.message, model, session, self)
		end
	end
	class ExceptionView < PublicTemplate
		CONTENT = ExceptionComposite
	end
end
