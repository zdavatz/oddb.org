#!/usr/bin/env ruby
# View::Drugs::Result -- oddb -- 03.03.2003 -- andy@jetnet.ch

require 'htmlgrid/form'
require 'view/form'
require 'view/resulttemplate'
require 'view/drugs/resultlist'
require 'view/resultfoot'
require 'view/searchbar'
require 'view/sponsorhead'
require 'view/drugs/rootresultlist'
require 'view/pager'
require 'sbsm/user'

module ODDB
class AdminUser < User; end
class CompanyUser < User; end
	module View
		module Drugs
class User < SBSM::KnownUser; end
class UnknownUser < SBSM::UnknownUser; end
class ExportCSV < View::Form
	CSS_CLASS = 'right'
	COMPONENTS = {
		[0,0,0]	=>	:new_feature,
		[0,0,1]	=>	:example,
		[0,0,2]	=>	:submit,
	}
	EVENT = :export_csv
	def init
		super
		data = {
			:zone					=>	@session.zone,
			:search_query	=>	@session.persistent_user_input(:search_query),
			:search_type	=>	@session.persistent_user_input(:search_type),
		}
		url = @lookandfeel._event_url(:export_csv, data)
		self.onsubmit = "location.href='#{url}';return false;"
	end
	def example(model, session)
		link = HtmlGrid::Link.new(:export_csv_example, model, 
			session, self)
		link.href = '/resources/downloads/Inderal.Preisvergleich.csv'
		link
	end
	def hidden_fields(context)
		hidden = super
		[:search_query, :search_type].each { |key|
			hidden << context.hidden(key.to_s, 
				@session.persistent_user_input(key))
		}	
		hidden
	end
	def new_feature(model, session)
		span = HtmlGrid::Span.new(model, session, self)
		span.value = @lookandfeel.lookup(:new_feature)
		span.set_attribute('style','color: red; margin: 5px; font-size: 8pt;')
		#span.set_attribute('style','color: red; margin: 5px; font-size: 11pt;')
		span
	end
end
class ResultForm < HtmlGrid::Composite
	COLSPAN_MAP	= {
		[0,2]	=> 2,
		[0,3]	=> 2,
	}
	COMPONENTS = {
		[0,0]		=>	:title_found,
		[1,0]		=>	View::Drugs::ExportCSV,
		[0,1]		=>	'price_compare',
		[1,1]		=>	SearchForm,
		[0,2]		=>	View::Drugs::ResultList,
		[0,3]		=>	View::ResultFoot,
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	ROOT_LISTCLASS = View::Drugs::RootResultList
	SYMBOL_MAP = {
	}
	CSS_MAP = {
		[0,0] =>	'result-found',
		[0,1] =>	'result-price-compare',
	}
	COMPONENT_CSS_MAP = {
		[0,3]	=>	'result-foot',
=begin
		[1,3]	=>	'legal-note',
=end
	}
	def init
		case @session.user
		when ODDB::AdminUser, ODDB::CompanyUser
			components.store([0,2], self::class::ROOT_LISTCLASS)
		end
		super
	end
	def title_found(model, session)
		query = session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_found, query, session.state.package_count)
	end
end
class Result < View::ResultTemplate
	CONTENT = ResultForm
	def head(model, session)
		if(@lookandfeel.enabled?(:sponsorlogo))
			View::SponsorHead.new(model, session, self)
		else
			View::LogoHead.new(model, session, self)
		end
	end
end
class EmptyResultForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0]		=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:title_none_found,
		[0,2]		=>	'e_empty_result',
		[0,3]		=>	'explain_search',
	}
	CSS_MAP = {
		[0,0]			=>	'search',	
		[0,1]			=>	'th',
		[0,2,1,2]	=>	'result-atc',
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	def title_none_found(model, session)
		query = session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_none_found, query)
	end
end
class EmptyResult < View::ResultTemplate
	CONTENT = View::Drugs::EmptyResultForm
end
class MigelEmptyResultForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0]		=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:title_none_found,
		[0,2]		=>	'e_empty_result',
		[0,3]		=>	'e_empty_migel_result',
	}
	CSS_MAP = {
		[0,0]			=>	'search',	
		[0,1]			=>	'th',
		[0,2,1,2]	=>	'result-atc',
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	def title_none_found(model, session)
		query = session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_none_found, query)
	end
end
class MigelEmptyResult < View::ResultTemplate
	CONTENT = View::Drugs::MigelEmptyResultForm
end
		end
	end
end
