#!/usr/bin/env ruby
# encoding: utf-8
# View::Interactions::CenteredSearchForm -- oddb -- 09.10.2012 -- yasaka@ywesee.com
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
      fields = []
      link = HtmlGrid::Link.new(:interaction_chooser, model, session, self)
      link.href  = @lookandfeel._event_url(:interaction_chooser, {})
      link.value = 'Instant'
      fields << link
      fields
    end
  end
end
class CenteredSearchComposite < View::CenteredSearchComposite
  COMPONENTS = {
    [0,0]   => :language_chooser,
    [0,1]   => :search_form,
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
  def search_form(model, session=@session)
    View::Interactions::CenteredSearchForm.new(model, session, self)
  end
  def substance_count(model, session)
    @session.app.substance_count.to_s << '&nbsp;'
  end
  def instant_search_enabled?
    @session.flavor == Session::DEFAULT_FLAVOR or
    @lookandfeel.enabled?(:ajax, false)
  end
end
class GoogleAdSenseComposite < View::GoogleAdSenseComposite
  CONTENT = CenteredSearchComposite
  GOOGLE_CHANNEL = '6290728057'
end
    end
  end
end
