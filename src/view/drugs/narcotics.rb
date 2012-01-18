#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Narcotics  -- oddb.org -- 18.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::Narcotics  -- oddb.org -- 16.11.2005 -- spfenninger@ywesee.com

require 'view/alphaheader'
require 'view/drugs/result'
require 'view/drugs/rootresultlist'

module ODDB
	module View
		module Drugs

class NarcoticsResultList < ResultList
  include AlphaHeader
  def compose_subheader(atc, offset)
    offset[1] -= 1 
  end
end
class NarcoticsRootResultList < RootResultList
  include AlphaHeader
  def compose_subheader(atc, offset)
    offset[1] -= 1 
  end
end
class NarcoticsResultComposite < HtmlGrid::Composite
	include ResultFootBuilder
	COLSPAN_MAP	= {}
	COMPONENTS = {
		[0,0,0]	=>	:title_found,
		[0,0,1]	=>	:dsp_sort,
		[0,1]		=>	'price_compare',
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	DEFAULT_LISTCLASS = View::Drugs::NarcoticsResultList
	ROOT_LISTCLASS = View::Drugs::NarcoticsRootResultList
	SYMBOL_MAP = { }
	CSS_MAP = {
		[0,0] =>	'result-found',
    [1,0] =>  'right',
		[0,1] =>	'list bold price-compare',
    [1,1] =>  'right',
	}
	def init
    if(@lookandfeel.enabled?(:breadcrumbs))
      components.store([0,0,0], :breadcrumbs)
      css_map.store([0,0], 'breadcrumbs')
    end
    if @lookandfeel.disabled?(:search)
      colspan_map.store [0,1], 2
    else
      components.store [1,1], SelectSearchForm
    end
    y = 2
    if(@lookandfeel.enabled?(:explain_sort, false))
      components.store([0,y], "explain_sort")
      css_map.store([0,y], "navigation")
      colspan_map.store([0,y], 2)
      y += 1
    end
    if @lookandfeel.enabled?(:oekk_structure, false)
      components.store([0,y], :explain_colors)
      css_map.store([0,y], "explain")
      colspan_map.store([0,y], 2)
      y += 1
    end
    colspan_map.store([0,y], 2)
    components.store([0,y], (@session.allowed?('edit', 'org.oddb.drugs')) \
                            ? self::class::ROOT_LISTCLASS \
                            : self::class::DEFAULT_LISTCLASS)
		if(@lookandfeel.enabled?(:export_csv))
			components.store([1,0], :export_csv)
    elsif(@lookandfeel.enabled?(:print, false))
      components.store([1,0], :print)
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
    breadcrumbs = []
    level = 2
    if @lookandfeel.enabled?(:home)
      dv = HtmlGrid::Span.new(model, @session, self)
      dv.css_class = "breadcrumb"
      dv.value = "&lt;"
      span1 = HtmlGrid::Span.new(model, @session, self)
      span1.css_class = "breadcrumb-#{level} bold"
      level -= 1
      link1 = HtmlGrid::Link.new(:back_to_home, model, @session, self)
      link1.href = @lookandfeel._event_url(:home)
      link1.css_class = "list"
      span1.value = link1
      breadcrumbs.push span1, dv
    end
    span2 = HtmlGrid::Span.new(model, @session, self)
    span2.css_class = "breadcrumb-#{level}"
    query = @session.persistent_user_input(:search_query).gsub('/', '%2F')
    prefix = if @session.language == 'de'
               'Betäubungsmittel '
             elsif @session.language == 'fr'
               'Stupéfiants '
             else
               'Narcotics '
             end
    span2.value = @lookandfeel.lookup(:list_for, prefix + query, model.package_count)
    span3 = HtmlGrid::Span.new(model, @session, self)
    span3.css_class = "breadcrumb"
    span3.value = '&ndash;'
    breadcrumbs.push span2, span3
  end
	def dsp_sort(model, session)
		url = @lookandfeel.event_url(:sort, {:sortvalue => :dsp})
		link = HtmlGrid::Link.new(:dsp_sort, model, @session, self)
		link.href = url
		link
	end
  def explain_colors(model, session=@session)
    comps = {
      [0,0]	=>	:explain_original,
      [0,1]	=>	:explain_generic,
      [0,2]	=>	'explain_unknown',
    }
    ExplainResult.new(model, @session, self, comps)
  end
	def export_csv(model, session=@session)
		if(@lookandfeel.enabled?(:export_csv))
			View::Drugs::DivExportCSV.new(model, @session, self)
		end
	end
  def print(model, session=@session)
    link = HtmlGrid::Link.new(:print, model, @session, self)
    link.set_attribute('onClick', 'window.print();')
    link.href = ""
    link
  end
  def title_found(model, session=@session)
    query = @session.persistent_user_input(:search_query)
    @lookandfeel.lookup(:title_found, query, model.package_count)
  end
end

class Narcotics < View::ResultTemplate
  include View::SponsorMethods
  CONTENT = NarcoticsResultComposite
  JAVASCRIPTS = ['bit.ly']
end
		end
	end
end
