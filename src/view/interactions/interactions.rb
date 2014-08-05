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
class InteractionsForm < View::Form
	COLSPAN_MAP = {
		[0,0]	=>	2,
	}
	COMPONENTS = {
		[0,0]		=>	:interactions_count,
		[0,1,0]	=>  'th_pointer_descr',
		[0,1,1]	=>  :backtracking,
		[0,1,2]	=>  'back_to_interactions',
		[1,1,0]	=>	:search_query,
		[1,1,1]	=>	:submit,
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
