#!/usr/bin/env ruby
# View::Interactions::Basket -- oddb -- 07.06.2004 -- mhuggler@ywesee.com

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
class BasketHeader < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'interaction_basket',
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'atc',
	}
end
class ExplainResult < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => "explain_auc_factor_5",
    [0,1] => "explain_auc_factor_2",
    [0,2] => "explain_auc_factor_125",
  }
  CSS_MAP = {
    [0,0,1,3] => 'list infos',
  }
end
class CyP450List < HtmlGrid::Component
  attr_accessor :base_substance
  def initialize(type, model, session, container)
    @interaction_type = type
    @list_index = container.list_index
    super(model, session, container)
  end
	def to_html(context)
		lang = @session.language
    other = @base_substance.en
    content = @model.collect { |substance, items| 
      next unless substance
      text = HtmlGrid::RichText.new(@model, @session, self)
      pub_med_search_link = HtmlGrid::Link.new(:pub_med_search_link, @model, @session, self)
      pub_med_search_link.href = \
        @lookandfeel.lookup(:pub_med_search_href, other, substance.en)
      items = items.sort_by { |item| 
        item.cyp_id
      }
      val = substance.send(lang) + " ("
      val << items.collect { |item|
        cid = item.cyp_id.to_s
        if((factor = item.auc_factor) && factor != "1")
          span = HtmlGrid::Span.new(@model, @session, self)
          factor = factor.gsub('.','')
          span.css_class = "auc-factor-#{factor}"
          span.css_id = "auc-factor-#{@list_index}-#{substance}-#{cid}"
          span.value = cid
          tooltip = HtmlGrid::Span.new(@model, @session, self)
          tooltip.value = @lookandfeel.lookup("explain_auc_factor_#{factor}")
          span.dojo_tooltip = tooltip
          cid = span.to_html(context)
        end
        cid
      }.join(',')
      val << ")"
      pub_med_search_link.value = val
      pub_med_search_link.target = "_blank"
      text << pub_med_search_link
      links = []
      items.each { |item|
        links.concat item.links
      }
      links.uniq!
      links.delete_if { |lnk| lnk.empty? }
      unless(links.empty?)
        text << '<br>'
        fspan = HtmlGrid::Span.new(@model, @session, self)
        fspan.value = @lookandfeel.lookup(:flockhart_link)
        fspan.css_class = 'italic'
        text << fspan
        links.each { |link|
          alink = HtmlGrid::Link.new(:abstract_link, @model, @session, self)
          alink.href = link.href
          alink.value = link.text
          text << [ "<br>", link.info, "<br>" ].join
          text << alink
        }
      end
      context.li { text.to_html(context) } 
    }.join
		context.ul { content } unless(content.empty?)
	end
end
class FiList < HtmlGrid::Component
  include AdditionalInformation
	def to_html(context)
		lang = @session.language
    content = @model.collect { |substance, interactions| 
      next unless substance
      text = HtmlGrid::RichText.new(@model, @session, self)
      text << substance.send(lang) << "<br>"
      interactions.each { |interaction|
        (fi = interaction.fachinfo) && (doc = fi.send(lang)) or next
        link = _fachinfo(fi)
        link.href << "/chapter/interactions/highlight/" << interaction.match
        name = HtmlGrid::Link.new(:name, doc, @session, self)
        name.href = link.href
        name.value = doc.name
        text << link << name << '<br>'
      }
      context.li { text.to_html(context) } 
    }.join
		context.ul { content } unless(content.empty?)
	end
end
class BasketSubstrates < HtmlGrid::List
  attr_reader :list_index
	BACKGROUND_SUFFIX = ' bg'
	COMPONENTS = {
		[0,0]		=>	:substance,
		[1,0]		=>	:cyp450s,
		[2,0]		=>	:inducers,
		[3,0]		=>	:inhibitors,
    [4,0]   =>  :observed,
	}
	CSS_MAP = {
		[0,0]		=>	'bold interaction-substance',
		[1,0,3]	=>	'interaction-connection',
    [4,0]   =>  'list',
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
  LEGACY_INTERFACE = false
	def cyp450s(model, session=@session)
    cyp450s = model.cyp450s
		unless(cyp450s.empty?)
      text = HtmlGrid::RichText.new(model, @session, self)
      str = cyp450s.keys.sort.join(', ')
			if(idx = str.rindex(','))
				str[idx,2] = @lookandfeel.lookup(:nbsp_and_nbsp)
			end
			text << "<b>" << str << "</b>"
      links = []
      cyp450s.sort.each { |key, item|
        links.concat item.links
      }
      links.uniq!
      links.delete_if { |lnk| lnk.empty? }
      unless(links.empty?)
        text << '<br>'
        fspan = HtmlGrid::Span.new(@model, @session, self)
        fspan.value = @lookandfeel.lookup(:flockhart_link)
        fspan.css_class = 'italic'
        text << fspan
        links.each { |link|
          if(href = link.href)
            alink = HtmlGrid::Link.new(:abstract_link, @model, @session, self)
            alink.href = href
            alink.value = link.text
            text << [ "<br>", link.info, "<br>" ].join
            text << alink
          end
        }
      end
      text
		end
	end
	def inhibitors(model, session=@sessino)
		interaction_list(model, :inhibitors)
	end
	def inducers(model, session=@session)
		interaction_list(model, :inducers)
	end
	def interaction_list(model, type)
    mdl = model.send(type)
		if(mdl && !mdl.empty?)
			list = CyP450List.new(type, mdl, @session, self)
      sub = model.substance
      list.base_substance = sub.effective_form || sub
      list
		end
	end
  def observed(model)
    FiList.new(model.observed, @session, self)
  end
  def substance(model)
    sub = model.substance
		lang = @session.language
		name = sub.send(lang)
    if(sub.has_effective_form? && !sub.is_effective_form?)
      sprintf("%s (%s)", sub.effective_form.send(lang), name)
    else
      name
    end
  end
end
class BasketForm < View::Form
	COLSPAN_MAP = {
		[0,0]	=>	2,
		[0,2]	=>	2,
		[0,3]	=>	2,
		[0,4]	=>	2,
	}
	COMPONENTS = {
		[0,0]		=>	:interaction_basket_count,
		[0,1,0]	=>	'interaction_basket_explain',
		[0,1,1]	=>  :pub_med_search_link,
		[1,1,0]	=>	:search_query,
		[1,1,1]	=>	:submit,
		[0,2]		=>	View::Interactions::BasketSubstrates,
		[0,3]		=>	:clear_interaction_basket,
    [0,4]   =>  ExplainResult,
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
  COMPONENT_CSS_MAP = {
		[0,4]	=>	'explain',
  }
	CSS_MAP = {
		[0,0] =>	'result-found',
		[0,1] =>	'list',
		[1,1]	=>	'search',	
		[0,3]	=>	'list bg',
		[0,4]	=>	'explain',
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
