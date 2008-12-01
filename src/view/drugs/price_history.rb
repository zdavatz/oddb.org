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
    [2,0] => :percent_exfactory,
    [3,0] => :public,
    [4,0] => :percent_public,
    [5,0] => :authorities,
    [6,0] => :origins,
    [7,0] => :mutation_codes,
  }
  CSS_HEAD_MAP = {
    [1,0] => 'subheading right',
    [3,0] => 'subheading right',
    [5,0] => 'subheading right',
  }
  CSS_MAP = {
    [0,0]   => 'list',
    [1,0,5] => 'list right',
    [6,0,2] => 'list',
  }
  DEFAULT_HEAD_CLASS = 'subheading'
  LEGACY_INTERFACE = false
  SORT_DEFAULT = :valid_from
  SORT_REVERSE = true
  SYMBOL_MAP = {
    :valid_from => HtmlGrid::DateValue,
  }
  def authorities(model)
    collect_data(model, :authority).collect do |key|
      span = HtmlGrid::Span.new model, @session, self
      span.value = @lookandfeel.lookup(:"price_authority_#{key}") do key end
      span.set_attribute("title", @lookandfeel.lookup(:"price_authority_title_#{key}") do key end)
      span
    end
  end
  def exfactory(model)
    formatted_price(:exfactory, model) if model.exfactory
  end
  def mutation_codes(model)
    collect_data(model, :mutation_code).collect do |key|
      @lookandfeel.lookup(:"sl_mutation_#{key}") do key end
    end.join(', ')
  end
  def origins(model)
    collect_data(model, :origin).inject([]) do |memo, url_and_date|
      url, date = url_and_date.split(' ')
      link = HtmlGrid::Link.new :origin, model, @session, self
      if match = /#{ODDB.config.bsv_archives}/.match(url)
        url = "http://www.galinfo.net/SL2007.WEb.external/BSV_xls_20#{match[1]}.zip"
      end
      link.href = link.value = url
      memo.push link
      if date
        memo.push ' ', date
      end
      memo
    end
  end
  def percent(pcnt)
    "(%+3.2f %%)" % pcnt if pcnt
  end
  def percent_exfactory(model)
    percent model.percent_exfactory
  end
  def percent_public(model)
    percent model.percent_public
  end
  def public(model)
    formatted_price(:public, model) if model.public
  end
  def collect_data(model, key)
    [:public, :exfactory].collect do |type|
      (price = model.send(type)) && price.send(key)
    end.compact.uniq
  end
end
class PriceHistoryComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0,0]	=>	:package_name,
    [0,0,1]	=>	" - ",
    [0,0,2]	=>	:article_24,
    [0,1]	  =>	PriceHistoryList,
  }
	CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0]	=>	'th',
  }
  LEGACY_INTERFACE = false
  def article_24(model)
    link = HtmlGrid::Link.new(:article_24, model, @session, self)
    link.href = @lookandfeel.lookup(:article_24_url)
    link.css_class = 'footnote'
    link
  end
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
