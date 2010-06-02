require 'view/external_links'
require 'view/language_chooser'
require 'view/publictemplate'

module ODDB
  module View
    module Drugs
class CompareSearchForm < View::Drugs::CenteredSearchForm
  attr_reader :index_name
  EVENT = :compare
  include View::UserSettings
  include View::ExternalLinks
  def init
    @index_name = 'oddb_package_name_with_size'
    super
  end
  COMPONENTS = {
    [0,0] => :language_chooser_short,
    [0,1] => 'drugs',
    [0,2] => :search_query,
    [0,3] => :generic_definition,
    [0,4] => :legal_note,
  }
  COMPONENT_CSS_MAP = {
    [0,0]	=> 'component',
    [0,4] => 'list',
  }
  CSS_MAP = {
    [0,0] => 'list',
    [0,1] => 'list',
    [0,2] => 'list',
    [0,3] => 'list',
    [0,4] => 'list',
  }
	SYMBOL_MAP = {
		:search_query	=>	View::AutocompleteSearchBar,
	}
end
class CompareSearch < View::PublicTemplate
  CONTENT = View::Drugs::CompareSearchForm
  CSS_CLASS = 'composite'
  HEAD = nil
  FOOT = nil
end
    end
  end
end
