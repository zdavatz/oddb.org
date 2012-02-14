#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Interactions::Interactions -- oddb.org -- 14.02.2012 -- mhatakeyama@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/value'
require 'view/form'
require 'view/searchbar'
require 'view/resulttemplate'

module ODDB
	module View
		module Interactions
class InteractionsHeader < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'interaction_basket',
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'atc',
	}
end
class InteractionsSubstrates < HtmlGrid::List
  attr_reader :list_index
	BACKGROUND_SUFFIX = ' bg'
	COMPONENTS = {
		[0,0]		=>	:active,
		[1,0]		=>	:passive,
		[2,0]		=>	:info,
		[3,0]		=>	:rating,
	}
	CSS_MAP = {
		[0,0]		=>	'list',
		[1,0]		=>	'list',
		[2,0]		=>	'list',
		[3,0]		=>	'list',
	}
	CSS_HEAD_MAP = {
		[0,0]	=>	'th',
		[1,0]	=>	'th',
		[2,0]	=>	'th',
		[3,0]	=>	'th',
	}
	CSS_CLASS = 'composite interaction-basket'
	DEFAULT_CLASS = HtmlGrid::Value
#	SORT_DEFAULT = :substance
	SUBHEADER = View::Interactions::InteractionsHeader
  LEGACY_INTERFACE = false
  def active(model, session=@session)
    if model.is_a?(Hash)
      model[:active] + " (" + model[:substance_active] + ")"
    end
  end
  def passive(model, session=@session)
    if model.is_a?(Hash)
      model[:passive] + " (" + model[:substance_passive] + ")"
    end
  end
  def info(model, session=@session)
    if model.is_a?(Hash)
      link = HtmlGrid::Link.new(:info, model, session, self) 
      args = {:atc_code => model[:active] + ',' + model[:passive]}
      link.href = @lookandfeel._event_url(:interaction_detail, args) do |args|
        args.map!{|arg| CGI.unescape(arg)}
      end
      link.value = model[:info]
      link
    end
  end
  def rating(model, session=@session)
    if model.is_a?(Hash)
      model[:rating]
    end
  end
end
class InteractionsForm < View::Form
	COLSPAN_MAP = {
		[0,0]	=>	2,
		[0,2]	=>	2,
	}
	COMPONENTS = {
		[0,0]		=>	:interactions_count,
		[0,1,0]	=>  'th_pointer_descr',
		[0,1,1]	=>  :backtracking,
		[0,1,2]	=>  'back_to_interactions',
		[1,1,0]	=>	:search_query,
		[1,1,1]	=>	:submit,
		[0,2]		=>	View::Interactions::InteractionsSubstrates,
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	CSS_MAP = {
		[0,0] =>	'result-found',
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
	def clear_interaction_basket(model, session)
		get_event_button(:clear_interaction_basket)
	end
end
class Interactions < View::ResultTemplate
	CONTENT = View::Interactions::InteractionsForm
end
		end
	end
end
