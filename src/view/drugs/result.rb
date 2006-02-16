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
require 'view/user/export'
require 'sbsm/user'

module ODDB
class AdminUser < User; end
class CompanyUser < User; end
	module View
		module Drugs
class User < SBSM::KnownUser; end
class UnknownUser < SBSM::UnknownUser; end
class ExportCSV < View::Form
	include View::User::Export
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
		super('Inderal.Preisvergleich.csv')
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
	include ResultFootBuilder
	COLSPAN_MAP	= {
		[0,2]	=> 2,
		[0,3]	=> 2,
	}
	COMPONENTS = {
		[0,0]		=>	:title_found,
		[0,0,1]	=>	:dsp_sort,
		[0,1]		=>	'price_compare',
		[1,1]		=>	SearchForm,
		[0,2]		=>	View::Drugs::ResultList,
		[0,3]		=>	:result_foot,
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
		[0,3]	=>	'explain-result'
	}
	COMPONENT_CSS_MAP = {
		[0,3]	=>	'result-foot',
=begin
		[1,3]	=>	'legal-note',
=end
	}
	def init
		case @session.user
		when ODDB::AdminUser, ODDB::CompanyUser, ODDB::PowerLinkUser
			components.store([0,2], self::class::ROOT_LISTCLASS)
		end
		if(@lookandfeel.enabled?(:export_csv))
			components.store([1,0], :export_csv)
		else
			colspan_map.store([0,0], 2)
		end
		super
	end
	def dsp_sort(model, session)
		url = @lookandfeel.event_url(:sort, {:sortvalue => :dsp})
		link = HtmlGrid::Link.new(:dsp_sort, model, @session, self)
		link.href = url
		link
	end
	def export_csv(model, session=@session)
		if(@lookandfeel.enabled?(:export_csv))
			View::Drugs::ExportCSV.new(model, @session, self)
		end
	end
	def title_found(model, session)
		query = session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_found, query, session.state.package_count)
	end
end
class Result < View::ResultTemplate
	include View::SponsorMethods
	CONTENT = ResultForm
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
		end
	end
end
