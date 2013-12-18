#!/usr/bin/env ruby
# encoding: utf-8
# View::Interactions::CenteredSearchForm -- oddb -- 20.12.2012 -- yasaka@ywesee.com
# View::Interactions::CenteredSearchForm -- oddb -- 26.05.2004 -- mhuggler@ywesee.com

require 'view/centeredsearchform'
require 'view/language_chooser'

module ODDB
  module View
    module Interactions
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
    @additional_javascripts = []
    super
    self.onload = "document.getElementById('interaction_searchbar').focus();"
    @index_name = 'oddb_package_name_with_size_company_name_ean13_fi'
    components.store([0,1,0], nil)
    components.store([0,1,1], nil)
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
end
class CenteredSearchComposite < View::CenteredSearchComposite
  COMPONENTS = {
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
  CSS_MAP = {
    [0,0,1,10] => 'list center',
  }
  COMPONENT_CSS_MAP = {
    [0,4] => 'legal-note',
  }
  def init
    # warm up
    @session.app.registrations.length
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
