#!/usr/bin/env ruby
# InteractionBasketView -- oddb -- 07.06.2004 -- maege@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/richtext'
require 'htmlgrid/value'
require 'view/form'
require 'view/searchbar'
require 'view/publictemplate'

module ODDB
	class InteractionBasketHeader < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	'interaction_basket',
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'atc-result',
		}
	end
	class InteractionList < HtmlGrid::Component
		def to_html(context)
			context.ul {
				@model.collect { |item| 
					text = HtmlGrid::RichText.new(@model, @session, self)
					text << item.substance_name
					pub_med_link = HtmlGrid::Link.new(:pub_med_link, @model, @session, self)
					pub_med_link.href = @lookandfeel.lookup(:pub_med_href, item.substance_name)
					pub_med_link.value = @lookandfeel.lookup(:pub_med)
					text << pub_med_link	
					item.links.each { |link|
						alink = HtmlGrid::Link.new(:abstract_link, @model, @session, self)
						alink.href = link.href
						alink.value = link.text
						text << [ "<br>", link.info, "<br>" ].join
						text << alink
					}
					context.li { text.to_html(context) } 
				}.join
			}
		end
	end
	class InteractionBasketSubstrates < HtmlGrid::List
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
		SUBHEADER = InteractionBasketHeader
		def cyp450s(model, session)
			unless(model.cyp450s.empty?)
				nbsp_and_nbsp = @lookandfeel.lookup(:nbsp_and_nbsp)
				cyp450s = model.cyp450s.join(nbsp_and_nbsp)
			end
		end
		def inhibitors(model, session)
			#puts 'inhibitors...'
			#puts model.inhibitors.size
			if((inhibitors = model.inhibitors) && !inhibitors.empty?)
				#puts 'yes'
				#puts inhibitors.class
				InteractionList.new(inhibitors.values, session, self)
			end
		end
		def inducers(model, session)
			#puts 'inducers ...'
			#puts model.inducers.size
			if((inducers = model.inducers) && !inducers.empty?)
				#puts 'yes'
				InteractionList.new(inducers.values, session, self)
			end
		end
	end
	class InteractionBasketForm < Form
		COLSPAN_MAP = {
			[0,0]	=>	2,
			[0,2]	=>	2,
		}
		COMPONENTS = {
			[0,0]		=>	:interaction_basket_count,
			[0,1]		=>	'interaction_basket_explain',
			[1,1]		=>	:search_query,
			[1,1,1]	=>	:submit,
			[0,2]		=>	InteractionBasketSubstrates,
			[0,3]		=>	:clear_interaction_basket,
		}
		CSS_CLASS = 'composite'
		EVENT = :search_interaction
		FORM_METHOD = 'GET'
		SYMBOL_MAP = {
			:search_query		=>	SearchBar,	
		}
		CSS_MAP = {
			[0,0] =>	'result-found',
			[0,1] =>	'result-price-compare',
			[1,1]	=>	'search',	
			[0,3]	=>	'button left padding',
		}
		def interaction_basket_count(model, session)
			count = session.interaction_basket_count
			@lookandfeel.lookup(:interaction_basket_count, count)
		end
		def clear_interaction_basket(model, session)
			get_event_button(:clear_interaction_basket)
		end
	end
	class InteractionBasketView < PublicTemplate
		CONTENT = InteractionBasketForm
	end
end
