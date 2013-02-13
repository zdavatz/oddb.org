#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Migel::Result -- oddb.org -- 13.02.2012 -- yasaka@ywesee.com
# ODDB::View::Migel::Result -- oddb.org -- 24.02.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Migel::Result -- oddb.org -- 04.10.2005 -- ffricker@ywesee.com

require 'htmlgrid/list'
require 'htmlgrid/value'
require 'htmlgrid/urllink'
require 'iconv'
require 'util/language'
require 'view/additional_information'
require 'view/dataformat'
require 'view/privatetemplate'
require 'view/pointervalue'
require 'view/resultfoot'
require 'view/lookandfeel_components'
require 'view/facebook'

module ODDB
  module View
    module Migel
class List < HtmlGrid::List
  include View::AdditionalInformation
  include DataFormat
  include View::LookandfeelComponents
  include View::Facebook
  COMPONENTS = {}
  CSS_CLASS = 'composite'
  CSS_HEAD_KEYMAP = {
    :feedback            => 'th right',
    :google_search       => 'th right',
    :facebook            => 'th right',
    :notify              => 'th right',
    :price               => 'th right',
  }
  CSS_KEYMAP = {
    :date                => 'list',
    :feedback            => 'list right',
    :google_search       => 'list',
    :limitation_text     => 'list',
    :migel_code          => 'list',
    :facebook            => 'list right',
    :notify              => 'list',
    :price               => 'list right',
    :product_description => 'list',
    :qty_unit            => 'list',
  }
  CSS_HEAD_MAP = {}
  CSS_MAP = {}
  LOOKANDFEEL_MAP = {
    :limitation_text => :nbsp,
  }
  SORT_HEADER = false
  SYMBOL_MAP = {
    :date => HtmlGrid::DateValue,
  }
  DEFAULT_CLASS = HtmlGrid::Value
  SORT_DEFAULT = nil
  LEGACY_INTERFACE = false
  # TODO
  # Refactor encoding of Migel::Item, -Product
  # See also items.rb, additional_information.rb
  %w(pharmacode ean_code article_name size companyname status ppub).each do |attr|
    define_method(attr) do |model, session|
      if model.respond_to?(attr) and model.send(attr)
        value = model.send(attr)
      else
        value = ''
      end
      value.to_s.force_encoding('utf-8')
    end
  end
  def init
    reorganize_components(:migel_list_components)
    @width = @components.keys.collect { |x, y| x }.max
    super
  end
  def facebook(model=@model, session=@session)
    code = model.migel_code.to_s.force_encoding('utf-8')
    facebook_link = @lookandfeel._event_url(:migel_search, {:migel_product => code.gsub(/\./, '')})
    [facebook_share(model, session, facebook_link), '&nbsp;']
  end
  def limitation_link(model)
    code = model.migel_code.to_s.force_encoding('utf-8')
    link = HtmlGrid::Link.new(:square_limitation, nil, @session, self)
    link.href = @lookandfeel._event_url(:migel_search, {:migel_limitation => code.delete('.')})
    link.set_attribute('title', @lookandfeel.lookup(:limitation_text))
    link.css_class = "square infos"
    link
  end
  def limitation_text(model)
    if(sltxt = model.limitation_text and !sltxt.to_s.empty?)
      limitation_link(model)
    else
      ''
    end
  end
  def product_description(model)
    code = model.migel_code.to_s.force_encoding('utf-8')
    link = PointerLink.new(:to_s, model, @session, self)
    text = [
      model,
      (model.product_text.to_s.force_encoding('utf-8') if(model.respond_to?(:product_text))),
    ].compact.collect { |item|
      if item.is_a? String
        item
      elsif item.respond_to?(@session.language)
        item.send(@session.language)
      end.force_encoding('utf-8')
    }.join(': ').gsub("\n", ' ')
    if(text.size > 60)
      text = text[0,57] << '...'
    end
    key = case code.length
          when 2
            :migel_group
          when 5
            :migel_subgroup
          else
            :migel_product
          end
    link.href  = @lookandfeel._event_url(:migel_search, {key => code.gsub(/\./, '')})
    link.value = text
    link
  end
  def migel_code(model)
    code = model.migel_code.to_s.force_encoding('utf-8')
    if model.respond_to?(:items) and items = model.items and !items.empty?
      # If a migelid has only inactive products, link to empty result
      link = PointerLink.new(:to_s, model, @session, self)
      link.value = code
      link.href  = @lookandfeel._event_url(:migel_search, {:migel_code => code.gsub(/\./, '')})
      link
    else
      code
    end
  end
end
class ResultList < View::Migel::List
  def compose_list(model=@model, offset=[0,0])
    bg_flag = false
    group = nil
    model.each { |subgroup|
      if(group != subgroup.group)
        group = subgroup.group
        compose_subheader(group, offset, 'list migel-group')
        offset = resolve_offset(offset, self::class::OFFSET_STEP)
      end
      compose_subheader(subgroup, offset)
      offset = resolve_offset(offset, self::class::OFFSET_STEP)
      products = subgroup.products
      super(products, offset)
      offset[1] += products.size
    }
  end
  def compose_subheader(item, offset, css='list atc')
    xval, yval = offset
    values = [limitation_text(item), migel_code(item), product_description(item)]
    x = xval
    values.each do |val|
      @grid.add(val, x, yval)
      x += 1
    end
    @grid.add_style(css, xval, yval, 3)
    @grid.set_colspan(xval + 2, yval, @width - xval - 1)
  end
end
class ExplainResult < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => 'explain_migel_position',
    [0,1] => 'explain_migel_date',
    [0,2] => 'explain_migel_price',
  }
  CSS_MAP = {
    [0,0,1,3] => 'explain infos',
  }
  CSS_ID = 'explain_result'
end
class ResultComposite < HtmlGrid::Composite
  include ResultFootBuilder
  EXPLAIN_RESULT = View::Migel::ExplainResult
  CSS_CLASS = 'composite'
  COMPONENTS = {
    [0,0] => ResultList,
    [0,1] => :result_foot,
  }
end
class Result < View::PrivateTemplate
  include View::Facebook
  CONTENT = ResultComposite
  SNAPBACK_EVENT = :result
  def to_html(context)
    # load javascript-sdk of fb in body
    html = super
    html = facebook_sdk + html
    html
  end
end
class EmptyResultForm < HtmlGrid::Form
  COMPONENTS = {
    [0,0,0] => :search_query,
    [0,0,1] => :submit,
    [0,1]   => :title_none_found,
    [0,2]   => 'e_empty_result',
    [0,3]   => 'e_empty_migel_result',
  }
  CSS_MAP = {
    [0,0]     => 'search',
    [0,1]     => 'th',
    [0,2,1,2] => 'list atc',
  }
  CSS_CLASS = 'composite'
  EVENT = :search
  FORM_METHOD = 'GET'
  SYMBOL_MAP = {
    :search_query => View::SearchBar,
  }
  def title_none_found(model, session)
    query = session.persistent_user_input(:search_query)
    @lookandfeel.lookup(:title_none_found, query)
  end
end
class EmptyResult < View::ResultTemplate
  CONTENT = EmptyResultForm
end
    end
  end
end
