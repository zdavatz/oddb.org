#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Interactions::InteractionDetail -- oddb.org -- 15.02.2012 -- mhatakeyama@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/richtext'
require 'htmlgrid/value'
require 'view/form'
require 'view/searchbar'
require 'view/resulttemplate'
require 'view/additional_information'

module ODDB
	module View
		module Interactions
class InteractionDetailHeader < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'interaction_basket',
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'atc',
	}
end
class InteractionDetailInnerComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite interaction-basket'
  COMPONENTS = {
    [0,0] =>  :mechanism,
    [0,1] =>  :effect,
    [0,2] =>  :clinic,
    [0,3] =>  'references',
  }
  CSS_MAP = {
    [0,3] =>  'bold',
  }
  LABELS = true
  DEFAULT_CLASS = HtmlGrid::Value
	SUBHEADER = View::Interactions::InteractionDetailHeader
  LEGACY_INTERFACE = false
  def mechanism(model, session=@session)
    value = HtmlGrid::Value.new(:mechanism, model, @session)
    value.value = model[:mechanism]
    value
  end
  def effect(model, session=@session)
    value = HtmlGrid::Value.new(:effect, model, @session)
    value.value = model[:effect]
    value
  end
  def clinic(model, session=@session)
    value = HtmlGrid::Value.new(:clinic, model, @session)
    value.value = model[:clinic]
    value
  end
end
class ReferenceList < HtmlGrid::List
  COMPONENTS = {
    [0,0] =>  :author,
    [1,0] =>  :journal,
    [2,0] =>  :year,
    [3,0] =>  :title,
  }
  CSS_MAP = {
    [0,0] =>  'list',
    [1,0] =>  'list',
    [2,0] =>  'list',
    [3,0] =>  'list',
  }
  DEFAULT_CLASS = HtmlGrid::Value
  DEFAULT_HEAD_CLASS = 'subheading'
  SORT_HEADER = false
  def author(model, session=@session)
    if model.is_a?(Hash)
      model[:author]
    end
  end
  def journal(model, session=@session)
    if model.is_a?(Hash)
      model[:journal]
    end
  end
  def year(model, session=@session)
    if model.is_a?(Hash)
      model[:year]
    end
  end
  def title(model, session=@session)
    if model.is_a?(Hash)
      model[:title]
    end
  end
end
class InteractionDetailComposite < HtmlGrid::Composite
  CSS_CLASS = 'composite'
  COMPONENTS = {
    [0,0] =>  'interaction_detail',
    [0,1] =>  View::Interactions::InteractionDetailInnerComposite,
    [0,2] =>  :references,
  }
  CSS_MAP = {
    [0,0] =>  'th',
    [0,2] =>  'list',
  }
  DEFAULT_CLASS = HtmlGrid::Value
  LEGACY_INTERFACE = false
  def references(model, session=@session)
    ReferenceList.new(model[:references], session, self)
  end
end
class InteractionDetailForm < View::Form
	COLSPAN_MAP = {
		[0,2]	=>	2,
	}
	COMPONENTS = {
    [0,0]   =>  '',
    [0,1,0] =>  'th_pointer_descr',
    [0,1,1] =>  :backtracking,
    [0,1,2] =>  :interactions,
    [0,1,3] =>  :interaction_detail,
    [1,1,0] =>  :search_query,
    [1,1,1] =>  :submit,
    [0,2]   =>  View::Interactions::InteractionDetailComposite,
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	CSS_MAP = {
		[0,0] =>	'list',
		[1,1]	=>	'search',	
	}
  def backtracking(model, session=@session)
    link = HtmlGrid::Link.new(:back_to_basket, model, session, self)
    substance_ids = @session.interaction_basket_ids
    atc_codes = @session.interaction_basket_atc_codes
    args = [:substance_ids, substance_ids, :atc_code, atc_codes.join(',')]
    link.href = @lookandfeel._event_url(:interaction_basket, args) do |args|
      args.map!{|arg| CGI.unescape(arg)}
    end
    link.set_attribute('class', 'th-pointersteps')
    link
  end
  def interactions(model, session=@session)
    link = HtmlGrid::Link.new(:back_to_interactions, model, session, self)
    atc_codes = @session.interaction_basket_atc_codes
    args = [:atc_code, atc_codes.join(',')]
    link.href = @lookandfeel._event_url(:interactions, args) do |args|
      args.map!{|arg| CGI.unescape(arg)}
    end
    link.set_attribute('class', 'th-pointersteps')
    link
  end
  def interaction_detail(model, session=@session)
    title = case @session.language
             when 'en'
              ' - Interaction Detail '
             when 'fr'
              " - Détail d'interaction "
             else
              ' - Interaktion Detail '
             end
     title + model[:title] 
  end
  def interaction_list(model, session)
    get_event_button(:interactions)
  end
	def interactions_count(model, session)
		count = model.length
		@lookandfeel.lookup(:interaction_count, count)
	end
	def pub_med_search_link(model, session)
		link = HtmlGrid::Link.new(:pub_med, @model, @session, self)
		link.css_class = 'list'
		link.target = '_blank'
		link.href = 'http://www.pubmedcentral.nih.gov/'
		link
	end
end
class InteractionDetail < View::ResultTemplate
	CONTENT = View::Interactions::InteractionDetailForm
end
		end
	end
end
