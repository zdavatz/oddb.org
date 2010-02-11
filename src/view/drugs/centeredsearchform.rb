#!/usr/bin/env ruby
# View::Drugs::CenteredSearchForm -- oddb -- 07.09.2004 -- mhuggler@ywesee.com

require 'htmlgrid/select'
require 'htmlgrid/divlist'
require 'view/centeredsearchform'
require 'view/facebook'
require 'view/google_ad_sense'

module ODDB
	module View
		module Drugs
class CenteredSearchForm < View::CenteredSearchForm
  include SearchBarMethods
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]			=>	View::TabNavigation,
		[0,1]			=>	'search_type',
		[0,2,0,1]	=>	:search_type,
		[0,3,0,2]	=>	:search_query,
		[0,4,0,3]	=>	:submit,
		[0,4,0,4]	=>	:search_reset,
	}
	SYMBOL_MAP = {
		:search_query	=>	View::SearchBar,	
	}
	COMPONENT_CSS_MAP = {
		[0,0]		=>	'component tabnavigation',
	}
	CSS_MAP = {
		[0,0]	=>	'center',
		[0,1]	=>	'list center',
		[0,2,1,3]	=>	'center',
	}
	EVENT = :search
end
class CenteredSearchComposite < View::CenteredSearchComposite
  include View::Facebook
	COMPONENTS = {
		[0,0]		=>	:screencast,
		[0,1]		=>	:language_chooser,
		[0,2]		=>	View::Drugs::CenteredSearchForm,
		[0,3]		=>	:search_explain, 
		[0,4]		=>	View::CenteredNavigation,
	}
	CSS_MAP = {
		[0,0,1,5]		=>	'list center',
	}
	def init
		if(@lookandfeel.enabled?(:just_medical_structure, false))
			@components = {
				[0,0]	  =>	:language_chooser,
				[0,1]	  =>	View::Drugs::CenteredSearchForm,
				[0,2]	  =>	'search_explain', 
				[0,3,0]	=>	'database_last_updated_txt',
				[0,3,1]	=>	:database_last_updated,
			}
		elsif(@lookandfeel.enabled?(:oekk_structure, false))
			@components = {
				[0,0]	  =>	View::Drugs::CenteredSearchForm,
				[0,1]	  =>	'search_explain',
				[0,2]	  =>	:recent_registrations,
				[0,3]		=>	:generic_definition,
				[0,4]	  =>	:legal_note,
			}
		elsif(@lookandfeel.enabled?(:atupri_web, false))
			@components = {
				[0,0]	  =>	View::Drugs::CenteredSearchForm,
				[0,1]	  =>	'search_explain', 
				[0,2,0]	=>	'database_last_updated_txt',
				[0,2,1]	=>	:database_last_updated,
				[0,3]		=>	:generic_definition,
			}
		elsif(@lookandfeel.enabled?(:data_counts))
			components.update({
				[0,4]		=>	:recent_registrations,
				[0,5,0]	=>	:database_size,
				[0,5,1]	=>	:sequences,
				[0,5,2]	=>	'comma_separator',
				[0,5,3]	=>	:narcotics_size,
				[0,5,4]	=>	:narcotics,
				[0,5,5]	=>	'comma_separator',
				[0,5,6]	=>	:vaccines_size,
				[0,5,7]	=>	:vaccines,
				[0,6,0]	=>	:fachinfo_size,
				[0,6,1]	=>	:fi_count_text,
				[0,6,2]	=>	'comma_separator',
				[0,6,3] =>	:patinfo_size,
				[0,6,4] =>	:pi_count_text,
				[0,7,0]	=>	:atc_ddd_size,
				[0,7,1]	=>	:ddd_count_text,
				[0,7,2]	=>	'comma_separator',
				[0,7,3]	=>	:limitation_size,
				[0,7,4]	=>	:sl_count_text,
				[0,8]		=>	:atc_chooser,
				[0,9,0]	=>	:new_feature,
				[0,9,1]	=>	:download_ebook,
				[0,10]	=>	:generic_definition,
				[0,11]	=>	:legal_note,
				[0,12]	=>	:paypal,
			})
      if @lookandfeel.enabled?(:facebook_fan, false)
        components.update [0,12] => :facebook_fan, [0,13] => :paypal
        css_map.store([0,4,1,10], 'list center')
      else
        css_map.store([0,4,1,9], 'list center')
      end
      component_css_map.store([0,11], 'legal-note')
		else
			components.update({
				[0,5,0]	=>	'database_last_updated_txt',
				[0,5,1]	=>	:database_last_updated,
      })
			css_map.store([0,5], 'list center')
      unless(@lookandfeel.disabled?(:generic_definition))
        components.store([0,6], :generic_definition)
			  css_map.store([0,6], 'list center')
      end
      unless(@lookandfeel.disabled?(:legal_note))
        components.store([0,7], :legal_note)
			  css_map.store([0,7], 'list center')
			  component_css_map.store([0,7], 'legal-note')
      end
		end
		super
	end
	def ddd_count_text(model, session)
		create_link(:ddd_count_text, 'http://www.whocc.no/atcddd/')
	end
	def sl_count_text(model, session)
		create_link(:sl_count_text, 
			'http://bag.e-mediat.net/SL2007.WEb.external/slindex.htm',
			:limitation_texts)
	end
	def fi_count_text(model, session)
		create_link(:fi_count_text, 
			'http://wiki.oddb.org/wiki.php?pagename=ODDB.Fi-Upload',
			:fachinfos)
	end
	def pi_count_text(model, session)
		create_link(:pi_count_text, 
			'http://wiki.oddb.org/wiki.php?pagename=ODDB.Pi-Upload', 
			:patinfos)
	end
	def create_link(text_key, href, event=nil)
		link = HtmlGrid::Link.new(text_key, @model, @session, self)
		if(event && @lookandfeel.enabled?(event))
			link.href = @lookandfeel._event_url(event)
		else
			link.href = href
		end
		link.set_attribute('class', 'list')
		link
	end
  def screencast(model, session=@session)
    if(@lookandfeel.enabled?(:screencast))
      link = HtmlGrid::Link.new(:screencast, model, @session, self)
      link.href = @lookandfeel.lookup(:screencast_url)
      link
    end
  end
	def substance_count(model, session)
		@session.app.substance_count
	end
	def narcotics(model, session)
		link = HtmlGrid::Link.new(:narcotics, model, session, self)
		link.href = @lookandfeel._event_url(:narcotics)
		link.set_attribute('class', 'list')
		link
	end
	def vaccines(model, session)
		link = HtmlGrid::Link.new(:vaccines, model, session, self)
		link.href = @lookandfeel._event_url(:vaccines)
		link.set_attribute('class', 'list')
		link
	end
end	
class RssPreview < HtmlGrid::DivComposite
  CSS_MAP = ['heading']
  def rss_image(model)
    if(link = title(model))
      img = HtmlGrid::Image.new(:minifi_title, model, @session, self)
      img.attributes['src'] = @lookandfeel.resource_global(:rss_feed)
      link.value = img
      link
    end
  end
end
class RssFeedbackList < HtmlGrid::DivList
  COMPONENTS = {
    [0,0] => :heading,
  }
  def heading(model)
    if(parent = model.item)
      link = HtmlGrid::Link.new(:feedbacks, model, @session, self)
      link.href = @lookandfeel._event_url(:feedbacks, :pointer => parent.pointer)
      link.value = case parent.odba_instance
                   when ODDB::Package
                     @lookandfeel.lookup(:feedback_rss_title,
                                         parent.name, parent.size)
                   when ODDB::Migel::Product
                     parent.name
                   end
      link
    end
  end
end
class RssFeedbacks < RssPreview
  COMPONENTS = {
    [0,0] => :rss_image,
    [1,0] => :title,
    [0,1] => RssFeedbackList,
  }
  def title(model)
    if(feedback = model.first)
      link = HtmlGrid::Link.new(:feedback_feed_title, model, @session, self)
      link.href = @lookandfeel._event_url(:rss, :channel => 'feedback.rss')
      link.css_class = 'list bold'
      link
    end
  end
end
class FachinfoNewsList < HtmlGrid::DivList
  COMPONENTS = {
    [0,0] => :name,
  }
  def name(model)
    link = PointerLink.new(:name_base, model, @session, self)
    link.value = model.localized_name(@session.language)
    link
  end
end
class FachinfoNews < RssPreview
  COMPONENTS = {
    [0,0] => :rss_image,
    [1,0] => :title,
    [0,1] => FachinfoNewsList,
  }
  def title(model)
    if((fachinfo = model.first) && (month = fachinfo.revision))
      link = HtmlGrid::Link.new(:fachinfo_news_title, model, @session, self)
      link.href = @lookandfeel._event_url(:rss, :channel => 'fachinfo.rss')
      link.value = [ @lookandfeel.lookup(:fachinfo_news_title), '<br>',
                     @lookandfeel.lookup("month_#{month.month}"),
                     month.year ].join(' ')
      link.css_class = 'list bold'
      link
    end
  end
end
class SLPriceNews < RssPreview
  COMPONENTS = {
    [0,0] => :rss_image,
    [1,0] => :title,
  }
  def title(model)
    title = "#{model}_feed_title"
    channel = "#{model}.rss"
    month, number = @session.rss_updates[channel]
    month ||= @@today
    link = HtmlGrid::Link.new(title, model, @session, self)
    link.href = @lookandfeel._event_url(:rss, :channel => channel)
    link.value = [ number.to_i, @lookandfeel.lookup(title), '<br>',
                   @lookandfeel.lookup("month_#{month.month}"),
                   month.year ].compact.join(' ')
    link.css_class = 'list bold'
    link
  end
end
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
	CONTENT = CenteredSearchComposite
	GOOGLE_CHANNEL = '2298340258'
  COMPONENTS = {
    [0,0]	=>	:rss_feeds_left,
    [1,0]	=>	:content,
    [2,0]	=>	:rss_feeds_right,
  }
  CSS_MAP = {
    [0,0] => 'sidebar',
    [2,0] => 'sidebar',
  }
  def rss_feeds_left(model, session=@session)
    content = []
    if(@lookandfeel.enabled?(:fachinfo_rss))
      content.push FachinfoNews.new(model.fachinfo_news[0,5], @session, self)
    end
    if(@lookandfeel.enabled?(:sl_introduction_rss))
      content.push SLPriceNews.new(:sl_introduction, @session, self)
    end
    if(@lookandfeel.enabled?(:price_cut_rss))
      content.push SLPriceNews.new(:price_cut, @session, self)
    end
    if(@lookandfeel.enabled?(:price_rise_rss))
      content.push SLPriceNews.new(:price_rise, @session, self)
    end
    content
  end
  def rss_feeds_right(model, session=@session)
    if(@lookandfeel.enabled?(:feedback_rss))
      RssFeedbacks.new(model.feedbacks, @session, self)
    end
  end
end
		end
	end
end
