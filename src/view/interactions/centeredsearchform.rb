#!/usr/bin/env ruby
# encoding: utf-8
# View::Interactions::CenteredSearchForm -- oddb -- 19.12.2012 -- yasaka@ywesee.com
# View::Interactions::CenteredSearchForm -- oddb -- 26.05.2004 -- mhuggler@ywesee.com

require 'view/centeredsearchform'
require 'view/language_chooser'

module ODDB
  module View
    module Interactions
class CenteredSearchForm < View::CenteredSearchForm
  include SearchBarMethods
  CSS_CLASS = 'composite'
  COMPONENTS = {
    [0,0]   => View::TabNavigation,
    [0,1,0] => 'search_type',
    [0,1,1] => :switch_links,
    [0,2]   => :search_query,
    [0,3]   => :submit,
  }
  SYMBOL_MAP = {
    :search_query => View::SearchBar,
  }
  COMPONENT_CSS_MAP = {
    [0,0] => 'component tabnavigation',
  }
  CSS_MAP = {
    [0,0] => 'center',
    [0,1] => 'list center',
    [0,2] => 'center',
    [0,3] => 'center',
  }
  EVENT = :search
  def switch_links(model, session=@session)
    if @container.instant_search_enabled?
      link = HtmlGrid::Link.new(:search_instant, model, session, self)
      args = { :search_form => 'instant' }
      link.href  = @lookandfeel._event_url(:home_interactions, args)
      link.value = 'Instant'
      link
    end
  end
end
class CenteredInstantSearchForm < CenteredSearchForm
  attr_reader :index_name
  EVENT = :interaction_chooser
  COMPONENTS = {
    [0,0]   => View::TabNavigation,
    [0,2,0] => :search_query,
  }
  SYMBOL_MAP = {
    :search_query => View::InteractionSearchBar,
  }
  def init
    super
    self.onload = "document.getElementById('interaction_searchbar').focus();"
    @index_name = 'oddb_package_name_with_size_company_name_ean13_fi'
    @additional_javascripts = []
    if @container.instant_search_only?
      components.store([0,1,0], nil)
      components.store([0,1,1], nil)
    else
      components.store([0,1,0], 'search_type')
      components.store([0,1,1], :switch_links)
    end
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
  def switch_links(model, session=@session)
    link = HtmlGrid::Link.new(:search_instant, model, session, self)
    args = { :search_form => 'normal' }
    link.href  = @lookandfeel._event_url(:home_interactions, args)
    link.value = 'Normal'
    link
  end
end
class CenteredSearchComposite < View::CenteredSearchComposite
  COMPONENTS = {
    [0,0]   => :language_chooser,
    [0,1]   => View::Interactions::CenteredSearchForm,
    [0,2]   => 'interaction_search_explain1',
    [0,3]   => 'interaction_search_explain2',
    [0,4]   => 'interaction_search_explain3',
    [0,6]   => View::CenteredNavigation,
    [0,7,0] => :database_size,
    [0,7,1] => 'database_size_text',
    [0,7,2] => 'comma_separator',
    [0,7,3] => :substance_count,
    [0,7,4] => 'substance_count_text',
    [0,7,5] => 'comma_separator',
    [0,7,6] => 'database_last_updated_txt',
    [0,7,7] => :database_last_updated,
    [0,8]   => :legal_note,
    [0,9]   => :paypal,
  }
  CSS_MAP = {
    [0,0,1,10] => 'list center',
  }
  COMPONENT_CSS_MAP = {
    [0,8] => 'legal-note',
  }
  def init
    if (@session.search_form == 'instant' and instant_search_enabled?) or
       (instant_search_only?)
      # warm up
      @session.app.registrations.length
      @components = {
        [0,0]   => :language_chooser,
        [0,1]   => View::Interactions::CenteredInstantSearchForm,
        [0,2]   => nil,
        [0,3,0] => :database_size,
        [0,3,1] => 'database_size_text',
        [0,3,2] => 'comma_separator',
        [0,3,3] => :substance_count,
        [0,3,4] => 'substance_count_text',
        [0,3,5] => 'comma_separator',
        [0,3,6] => 'database_last_updated_txt',
        [0,3,7] => :database_last_updated,
        [0,4]   => :legal_note,
        [0,5]   => :paypal,
      }
    end
    super
  end
  def substance_count(model, session=@session)
    @session.app.substance_count.to_s << '&nbsp;'
  end
  def instant_search_enabled?
    @session.flavor == Session::DEFAULT_FLAVOR or
    @lookandfeel.enabled?(:ajax, false)
  end
  def instant_search_only?
    @session.flavor == 'just-medical'
  end
end
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
  CONTENT = CenteredSearchComposite
  GOOGLE_CHANNEL = '6290728057'
end
    end
  end
end
