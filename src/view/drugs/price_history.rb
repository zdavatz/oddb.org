#!/usr/bin/env ruby
# View::Drugs::PriceHistory -- oddb.org -- 24.11.2008 -- hwyss@ywesee.com

require 'htmlgrid/datevalue'
require 'view/dataformat'
require 'view/drugs/privatetemplate'
require 'view/drugs/compare'

module ODDB
  module View
    module Drugs
class PriceHistoryList < HtmlGrid::List
  include DataFormat
  COMPONENTS = {
    [0,0] => :valid_from,
    [1,0] => :exfactory,
    [2,0] => :public,
    [3,0] => :origins,
    [4,0] => :mutation_codes,
  }
  CSS_HEAD_MAP = {
    [1,0] => 'subheading right',
    [2,0] => 'subheading right',
  }
  CSS_MAP = {
    [0,0]   => 'list',
    [1,0,2] => 'list right',
    [3,0,2] => 'list',
  }
  DEFAULT_HEAD_CLASS = 'subheading'
  LEGACY_INTERFACE = false
  SORT_DEFAULT = :valid_from
  SORT_REVERSE = true
  SYMBOL_MAP = {
    :valid_from => HtmlGrid::DateValue,
  }
  def exfactory(model)
    formatted_price(:exfactory, model)
  end
  def mutation_codes(model)
    collect_data(model, :mutation_code).collect do |key|
      @lookandfeel.lookup(:"sl_mutation_#{key}") do key end
    end.join(', ')
  end
  def origins(model)
    collect_data(model, :origin).join(', ')
  end
  def public(model)
    formatted_price(:public, model)
  end
  def collect_data(model, key)
    [:public, :exfactory].collect do |type|
      (price = model.send(type)) && price.send(key)
    end.compact.uniq
  end
end
class PriceHistoryComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0]	=>	:package_name,
    [0,1]	=>	PriceHistoryList,
  }
	CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0]	=>	'th',
  }
  LEGACY_INTERFACE = false
  def package_name(model)
    if pack = model.package
      sprintf "%s&nbsp;-&nbsp;%s&nbsp;-&nbsp;%s&nbsp;%s", pack.name, 
              pack.size, pack.iksnr, pack.ikscd
    end
  end
end
class PriceHistory < PrivateTemplate
  include InsertBackbutton
  CONTENT = PriceHistoryComposite
	SNAPBACK_EVENT = :result
  def init
    if pack = @model.package
      @model.pointer_descr = @lookandfeel.lookup(:price_history_for, pack.name)
    else
      @model.pointer_descr = @lookandfeel.lookup(:price_history)
    end
    super
  end
end
    end
  end
end
