#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::CenteredSearchForm -- oddb.org -- 15.01.2013 -- yasaka@ywesee.com
# ODDB::View::Drugs::CenteredSearchForm -- oddb.org -- 30.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::CenteredSearchForm -- oddb.org -- 07.09.2004 -- mhuggler@ywesee.com

require 'htmlgrid/select'
require 'htmlgrid/divlist'
require 'htmlgrid/link'
require 'view/centeredsearchform'
require 'view/facebook'
require 'view/google_ad_sense'

module ODDB
	module View
		module Drugs
class CenteredSearchForm < View::CenteredSearchForm
  include SearchBarMethods
	CSS_CLASS = 'tundra composite'
  COMPONENTS = {
    [0,0]      => View::TabNavigation,
    [0,1,0]    => 'search_type',
    [0,1,1]    => :switch_links,
    [0,2,0,1]  => :search_type,
    [0,3,0,2]  => :search_query,
    [0,3]      => :progress_bar,
    [0,4,0,3]  => :submit,
  }
	SYMBOL_MAP = {
		:search_query => View::SearchBar,
	}
	COMPONENT_CSS_MAP = {
		[0,0]		=>	'component tabnavigation',
	}
	CSS_MAP = {
		[0,0]     => 'center',
		[0,1]     => 'list center',
		[0,2,1,3] => 'center',
	}
	EVENT = :search
  def init
    super
    @additional_javascripts ||= []
    # This method is called in setTimeout() from SearchBar class
    @additional_javascripts.push <<-JS
require(["dojo/parser", "dijit/ProgressBar"], function(){
  show_progressbar = function(searchbar_id){
    var progressBar = searchProgressBar.set({
      style: "display:block;",
      value: Infinity,
    });
    var searchbar = dojo.byId(searchbar_id);
    searchbar.style.display = "none";
  };
});
    JS
  end
  def javascripts(context)
    scripts = ''
    @additional_javascripts.each do |script|
      args = {
        'type'     => 'text/javascript',
        'language' => 'JavaScript',
      }
      scripts << context.script(args) do script end
    end
    scripts
  end
  def to_html(context)
    javascripts(context).to_s << super
  end
  def progress_bar(model, session=@session)
    div =  HtmlGrid::Div.new(model, session, self)
    div.set_attribute('data-dojo-type', 'dijit.ProgressBar')
    div.set_attribute('data-dojo-id',   'searchProgressBar')
    div.set_attribute(:style, 'margin:10px auto; width:300px; display:none;')
    div
  end
  def switch_links(model, session=@session)
    if @container.instant_search_enabled?
      fields = []
      link = HtmlGrid::Link.new(:search_instant, model, session, self)
      args = { :search_form => 'instant' }
      link.href  = @lookandfeel._event_url(:home, args)
      link.value = 'Instant'
      fields << link
      fields << '&nbsp;|&nbsp;'
      fields << _link_to_fachinfo_search
      fields
    end
  end
  def _link_to_fachinfo_search
    link = HtmlGrid::Link.new(:fachinfo_search, @model, @session, self)
    link.href  = @lookandfeel._event_url(:fachinfo_search, {})
    link.value = @lookandfeel.lookup(:fachinfo_search)
    link
  end
end
class CenteredCompareSearchForm < CenteredSearchForm
  attr_reader :index_name
  EVENT = :compare
  COMPONENTS = {
    [0,0]   => View::TabNavigation,
    [0,1,0] => 'search_type',
    [0,1,1] => :switch_links,
    [0,2,0] => :search_query,
    [0,2]   => :progress_bar,
  }
  SYMBOL_MAP = {
    :search_query => View::AutocompleteSearchBar,
  }
  def init
    @index_name = 'oddb_package_name_with_size'
    @additional_javascripts ||= [] # for AutocompleteSearchBar
    super
  end
  def switch_links(model, session=@session)
    fields = []
    link = HtmlGrid::Link.new(:search_instant, model, session, self)
    args = { :search_form => 'plus' }
    link.href  = @lookandfeel._event_url(:home, args)
    link.value = 'Plus'
    fields << link
    fields << '&nbsp;|&nbsp;'
    fields << _link_to_fachinfo_search
    fields
  end
end
class CenteredSearchComposite < View::CenteredSearchComposite
  include View::Facebook
	COMPONENTS = {
		[0,0]		=>	:screencast,
		[0,1]		=>	:language_chooser,
		[0,2]		=>	:search_form,
		[0,3]		=>	:search_explain, 
		[0,4]		=>	View::CenteredNavigation,
	}
	CSS_MAP = {
		[0,0,1,5]		=>	'list center',
	}
	def init
		if(@lookandfeel.enabled?(:just_medical_structure, false))
			@components = {
				[0,0]	  =>	'nbsp',
				[0,1]	  =>	:search_form,
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
				[0,0]	  =>	:search_form,
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
				[0,10]	=>	:download_app,
				[0,11]	=>	:download_amiko,
				[0,12]	=>	:download_amiko_os_x,
				[0,13]	=>	:download_amiko_win,
				[0,14]	=>	:generic_definition,
				[0,16]	=>	:legal_note,
				[0,17]	=>	:paypal,
			})
      if @lookandfeel.enabled?(:facebook_fan, false)
        components.update [0,14] => :facebook_fan, [0,15] => :paypal
        css_map.store([0,4,1,12], 'list center')
      else
        css_map.store([0,4,1,11], 'list center')
      end
      component_css_map.store([0,13], 'legal-note')
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
  def search_form(model, session=@session)
    if(@session.search_form == 'instant' and instant_search_enabled?)
        View::Drugs::CenteredCompareSearchForm.new(model, session, self)
    else # plus
      View::Drugs::CenteredSearchForm.new(model, session, self)
    end
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
  def instant_search_enabled?
    @session.flavor == Session::DEFAULT_FLAVOR or
    @lookandfeel.enabled?(:ajax, false)
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
      if parent.is_a?(ODDB::Package)
        link.href = @lookandfeel._event_url(:feedbacks, [:reg, parent.iksnr, :seq, parent.seqnr, :pack, parent.ikscd])
      end
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
    if(model.respond_to?(:localized_name))
      link = HtmlGrid::Link.new(:name_base, model, @session, self)
      link.value = model.localized_name(@session.language)
      if regs = model.registrations and reg = regs.first and reg.iksnr
        link.href = @lookandfeel._event_url :fachinfo, :swissmedicnr => model.registrations.first.iksnr
      end
      link
    end
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
class RecallNews < SLPriceNews; end
class HpcNews < SLPriceNews; end
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
    return unless(@lookandfeel.enabled?(:rss_box))
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
    if(@lookandfeel.enabled?(:recall_rss))
      content.push RecallNews.new(:recall, @session, self)
    end
    if(@lookandfeel.enabled?(:hpc_rss))
      content.push HpcNews.new(:hpc, @session, self)
    end
    content
  end
  def rss_feeds_right(model, session=@session)
    return unless(@lookandfeel.enabled?(:rss_box))
    if(@lookandfeel.enabled?(:feedback_rss))
      RssFeedbacks.new(model.feedbacks, @session, self)
    end
  end
end
		end
	end
end
