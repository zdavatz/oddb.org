#!/usr/bin/env ruby
# View::Interactions::Basket -- oddb -- 07.06.2004 -- mhuggler@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/richtext'
require 'htmlgrid/value'
require 'view/form'
require 'view/searchbar'
require 'view/resulttemplate'

module ODDB
	module View
		module Interactions
class BasketHeader < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'interaction_basket',
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'atc-result',
	}
end
class List < HtmlGrid::Component
	def to_html(context)
		context.ul {
			@model.collect { |substance, items| 
				text = HtmlGrid::RichText.new(@model, @session, self)
				pub_med_search_link = HtmlGrid::Link.new(:pub_med_search_link, @model, @session, self)
				pub_med_search_link.href = \
					@lookandfeel.lookup(:pub_med_search_href, substance.en)
				cyp_ids = items.collect { |item| 
					item.parent(@session).cyp_id
				}
				pub_med_search_link.value = substance.name \
					+ " (#{cyp_ids.sort.join(',')})"
				pub_med_search_link.target = "_blank"
				text << pub_med_search_link
				items.each { |item|
					item.links.each { |link|
						alink = HtmlGrid::Link.new(:abstract_link, @model, @session, self)
						alink.href = link.href
						alink.value = link.text
						text << [ "<br>", link.info, "<br>" ].join
						text << alink
					}
				}
				context.li { text.to_html(context) } 
			}.join
		}
	end
end
class BasketSubstrates < HtmlGrid::List
	BACKGROUND_SUFFIX = ' bg'
	COMPONENTS = {
		[0,0]		=>	:substance,
		[1,0]		=>	:cyp450s,
		[2,0]		=>	:inducers,
		[3,0]		=>	:inhibitors,
		
	}
	CSS_MAP = {
		[0,0]		=>	'bold interaction-substance',
		[1,0,3]	=>	'interaction-connection',
	}
	CSS_HEAD_MAP = {
		[0,0]	=>	'th',
		[1,0]	=>	'th',
		[2,0]	=>	'th',
		[3,0]	=>	'th',
	}
	CSS_CLASS = 'composite interaction-basket'
	DEFAULT_CLASS = HtmlGrid::Value
	SORT_DEFAULT = :substance
	SUBHEADER = View::Interactions::BasketHeader
	def cyp450s(model, session)
		unless(model.cyp450s.empty?)
			str = model.cyp450s.sort.join(', ')
			if(idx = str.rindex(','))
				str[idx,2] = @lookandfeel.lookup(:nbsp_and_nbsp)
			end
			str
		end
	end
	def inhibitors(model, session)
		interaction_list(model.inhibitors)
	end
	def inducers(model, session)
		interaction_list(model.inducers)
	end
	def interaction_list(model)
		if(model && !model.empty?)
			View::Interactions::List.new(model, @session, self)
		end
	end
end
class BasketForm < View::Form
	COLSPAN_MAP = {
		[0,0]	=>	2,
		[0,2]	=>	2,
	}
	COMPONENTS = {
		[0,0]		=>	:interaction_basket_count,
		[0,1]		=>	'interaction_basket_explain',
		[0,1,1]	=>  :pub_med_search_link,
		[1,1]		=>	:search_query,
		[1,1,1]	=>	:submit,
		[0,2]		=>	View::Interactions::BasketSubstrates,
		[0,3]		=>	:clear_interaction_basket,
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	CSS_MAP = {
		[0,0] =>	'result-found',
		[0,1] =>	'list',
		[1,1]	=>	'search',	
		[0,3]	=>	'button left padding',
	}
	def interaction_basket_count(model, session)
		count = session.interaction_basket_count
		@lookandfeel.lookup(:interaction_basket_count, count)
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
class Basket < View::ResultTemplate
	CONTENT = View::Interactions::BasketForm
end
		end
	end
end
