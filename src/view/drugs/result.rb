#!/usr/bin/env ruby
# View::Drugs::Result -- oddb -- 03.03.2003 -- andy@jetnet.ch

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
class DivExportCSV < HtmlGrid::DivForm
	include View::User::Export
	COMPONENTS = {
		[0,0]	=>	:new_feature,
		[1,0]	=>	:example,
		[2,0]	=>	:submit,
	}
  LEGACY_INTERFACE = false
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
	def example(model)
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
	def new_feature(model)
		span = HtmlGrid::Span.new(model, @session, self)
		span.value = @lookandfeel.lookup(:new_feature)
		span.set_attribute('style','color: red; margin: 5px; font-size: 8pt;')
		#span.set_attribute('style','color: red; margin: 5px; font-size: 11pt;')
		span
	end
end
class ResultComposite < HtmlGrid::Composite
	include ResultFootBuilder
	COLSPAN_MAP	= {
		[0,2]	=> 2,
	}
	COMPONENTS = {
		[0,0,0]	=>	:title_found,
		[0,0,1]	=>	:dsp_sort,
		[0,1]		=>	'price_compare',
		[1,1]		=>	SelectSearchForm,
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	DEFAULT_LISTCLASS = View::Drugs::ResultList
	ROOT_LISTCLASS = View::Drugs::RootResultList
	SYMBOL_MAP = { }
	CSS_MAP = {
		[0,0] =>	'result-found',
    [1,0] =>  'right',
		[0,1] =>	'list bold',
    [1,1] =>  'right',
	}
	def init
    if(@lookandfeel.enabled?(:breadcrumbs))
      components.store([0,0,0], :breadcrumbs)
      css_map.store([0,0], 'breadcrumbs')
    end
    y = 2
    if(@lookandfeel.enabled?(:explain_sort, false))
      components.store([0,y], "explain_sort")
      css_map.store([0,y], "navigation")
      y += 1
      colspan_map.store([0,y], 2)
    end
    components.store([0,y], (@session.allowed?('edit', 'org.oddb.drugs')) \
                            ? self::class::ROOT_LISTCLASS \
                            : self::class::DEFAULT_LISTCLASS)
		if(@lookandfeel.enabled?(:export_csv))
			components.store([1,0], :export_csv)
		else
			colspan_map.store([0,0], 2)
		end
    code = @session.persistent_user_input(:code)
    unless(@model.respond_to?(:overflow?) && @model.overflow? \
           && (code.nil? || !@model.any? { |atc| atc.code == code }))
      y += 1
      components.store([0,y], :result_foot)
      colspan_map.store([0,y], 2)
    end
		super
	end
  def breadcrumbs(model, session=@session)
    dv = HtmlGrid::Span.new(model, @session, self)
    dv.css_class = "breadcrumb"
    dv.value = "&lt;"
    span1 = HtmlGrid::Span.new(model, @session, self)
    span1.css_class = "breadcrumb-2 bold"
    link1 = HtmlGrid::Link.new(:back_to_home, model, @session, self)
    link1.href = @lookandfeel._event_url(:home)
    link1.css_class = "list"
    span1.value = link1
    span2 = HtmlGrid::Span.new(model, @session, self)
    span2.css_class = "breadcrumb-1"
    query = @session.persistent_user_input(:search_query)
    span2.value = @lookandfeel.lookup(:list_for, query, model.package_count)
    span3 = HtmlGrid::Span.new(model, @session, self)
    span3.css_class = "breadcrumb"
    span3.value = '&ndash;'
    [span1, dv, span2, span3]
  end
	def dsp_sort(model, session)
		url = @lookandfeel.event_url(:sort, {:sortvalue => :dsp})
		link = HtmlGrid::Link.new(:dsp_sort, model, @session, self)
		link.href = url
		link
	end
	def export_csv(model, session=@session)
		if(@lookandfeel.enabled?(:export_csv))
			View::Drugs::DivExportCSV.new(model, @session, self)
		end
	end
  def title_found(model, session=@session)
    query = @session.persistent_user_input(:search_query)
    @lookandfeel.lookup(:title_found, query, model.package_count)
  end
end
class Result < View::ResultTemplate
	include View::SponsorMethods
	CONTENT = ResultComposite
end
class EmptyResultComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	SelectSearchForm,
		[0,1]		=>	:title_none_found,
		[0,2]		=>	'e_empty_result',
		[0,3]		=>	'explain_search',
	}
	CSS_MAP = {
		[0,0]			=>	'search',	
		[0,1]			=>	'th',
		[0,2,1,2]	=>	'list atc',
	}
	CSS_CLASS = 'composite'
	def title_none_found(model, session)
		query = session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_none_found, query)
	end
end
class EmptyResult < View::ResultTemplate
	CONTENT = View::Drugs::EmptyResultComposite
end
		end
	end
end
