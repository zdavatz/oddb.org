#!/usr/bin/env ruby
# View::Drugs::CenteredSearchForm -- oddb -- 07.09.2004 -- mhuggler@ywesee.com

require 'htmlgrid/select'
require 'htmlgrid/divlist'
require 'view/centeredsearchform'
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
				[0,9,1]	=>	:download_generics,
				[0,10]		=>	:generic_definition,
				[0,11]	=>	:legal_note,
				[0,12]	=>	:paypal,
			})
			css_map.store([0,4,1,9], 'list center')
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
			'http://www.galinfo.net',
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
    img = HtmlGrid::Image.new(:minifi_title, model, @session, self)
    img.attributes['src'] = @lookandfeel.resource_global(:rss_feed)
    link = title(model)
    link.value = img
    link
  end
end
class MiniFiList < HtmlGrid::DivList
  COMPONENTS = {
    [0,0] => :heading,
  }
  def heading(model)
    link = PointerLink.new(:heading, model, @session, self)
    link.value = model.send(@session.language).heading
    link
  end
end
class MiniFis < RssPreview
  COMPONENTS = {
    [0,0] => :rss_image,
    [1,0] => :title,
    [0,1] => MiniFiList,
  }
  def title(model)
    if((minifi = model.first) && (month = minifi.publication_date))
      link = HtmlGrid::Link.new(:minifi_title, model, @session, self)
      link.href = @lookandfeel._event_url(:rss, :channel => 'minifi.rss')
      link.value = [ @lookandfeel.lookup(:minifi_title), '<br>',
                     @lookandfeel.lookup("month_#{month.month}"),
                     month.year ].join(' ')
      link.css_class = 'list bold'
      link
    end
  end
end
class FachinfoNewsList < HtmlGrid::DivList
  COMPONENTS = {
    [0,0] => :name_base,
  }
  SYMBOL_MAP = {
    :name_base => PointerLink,
  }
  def name(model)
    link = PointerLink.new(:name_base, model, @session, self)
    link.value = model.name_base
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
=begin
    group = @session.log_group(:bsv_sl)
    month = group.newest_date
    while((log = group.log(month)) && !log.change_flags.any? { |key, vals|
      vals.include?(model) } )
      month = month << 1
    end
=end
    title = "#{model}_feed_title"
    link = HtmlGrid::Link.new(title, model, @session, self)
    link.href = @lookandfeel._event_url(:rss, :channel => "#{model}.rss")
=begin
    link.value = [ @lookandfeel.lookup(title), '<br>',
                   @lookandfeel.lookup("month_#{month.month}"),
                   month.year ].join(' ')
=end
    link.value = @lookandfeel.lookup(title)
    link.css_class = 'list bold'
    link
  end
end
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
	CONTENT = CenteredSearchComposite
	GOOGLE_CHANNEL = '2298340258'
  COMPONENTS = {
    [0,0]	=>	:rss_feeds,
    [1,0]	=>	:content,
    [2,0]	=>	:ad_sense,
  }
  CSS_MAP = {
    [0,0] => 'sidebar',
    [2,0] => 'sidebar',
  }
  def rss_feeds(model, session=@session)
    content = []
    if(@lookandfeel.enabled?(:minifis))
      content.push MiniFis.new(model.minifis, @session, self)
    end
    if(@lookandfeel.enabled?(:fachinfo_news))
      content.push FachinfoNews.new(model.fachinfo_news, @session, self)
    end
    if(@lookandfeel.enabled?(:sl_price_news))
      content.push SLPriceNews.new(:price_cut, @session, self)
      content.push SLPriceNews.new(:price_rise, @session, self)
    end
    content
  end
end
		end
	end
end
