#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Migel::Product -- oddb.org -- 29.08.2012 -- yasaka@ywesee.com
# ODDB::View::Migel::Product -- oddb.org -- 24.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Migel::Product -- oddb.org -- 05.10.2005 -- ffricker@ywesee.com

require 'view/dataformat'
require 'view/privatetemplate'
require 'view/pointervalue'
require 'view/migel/result'
require 'htmlgrid/urllink'
require 'view/additional_information'

module ODDB
  module View
    module Migel
class AccessoryList < HtmlGrid::List
  COMPONENTS = {
    [0,0] => :migel_code,
    [1,0] => :description,
  }
  CSS_MAP = {
    [0,0] => 'top list',
    [1,0] => 'list',
  }
  DEFAULT_CLASS = HtmlGrid::Value
  DEFAULT_HEAD_CLASS = 'subheading'
  SORT_HEADER = false
  SORT_DEFAULT = :migel_code
  SYMBOL_MAP = {
    :migel_code => PointerLink,
  }
  LOOKANDFEEL_MAP = {
    :migel_code  => :title_accessories,
    :description => :nbsp,
  }
  def migel_code(model=@model, session=@session)
    code = model.migel_code.to_s.force_encoding('utf-8')
    link = PointerLink.new(:to_s, model, @session, self)
    link.value = code
    event = :migel_search
    link.href = @lookandfeel._event_url(event, {:migel_product => code.delete('.')})
    link
  end
end
class AccessoryOfList < AccessoryList
  LOOKANDFEEL_MAP = {
    :migel_code  => :title_accessories_of,
    :description => :nbsp,
  }
  def migel_code(model=@model, session=@session)
    if model.is_a?(DRbObject)
      # Actually, model is a Migel::Model::Product instance.
      model.pharmacode.to_s.force_encoding('utf-8')
    else
      ''
    end
  end
end
class ProductInnerComposite < HtmlGrid::Composite
  include AdditionalInformation
  include DataFormat
  SYMBOL_MAP = {
    :date           => HtmlGrid::DateValue,
    :feedback_label => HtmlGrid::LabelText,
  }
  COMPONENTS = {
    [0,0] => :migel_code,
    [0,1] => :group,
    [0,2] => :subgroup,
    [0,3] => :description,
    [0,4] => :product_text,
    [0,5] => :limitation_text,
    [0,6] => :date,
    [0,7] => :price,
    [1,7] => :qty_unit,
    [0,8] => :feedback_label,
    [1,8] => :feedback,
  }
  CSS_MAP = {
    [0,0,1,9] => 'list top',
    [1,0,1,9] => 'list',
  }
  LABELS = true
  DEFAULT_CLASS = HtmlGrid::Value
  LEGACY_INTERFACE = false
  @@migel_pattern = /Pos(?:ition|\.)?\s*(\d\d)(?:\.(\d\d)(?:\.(\d\d\.\d\d\.\d))?)?/u
  def description(model, key = :migel_product)
    value = HtmlGrid::Value.new(key, model, @session, self)
    group_cd    = ''
    subgroup_cd = ''
    product_cd  = ''
    args = []
    if (model and model.is_a? String)
      str = model
    elsif model.respond_to?(@session.language)
      str = model.send(@session.language)
    end
    if (str)
      str = str.to_s.force_encoding('utf-8')
      value.value = str.gsub(@@migel_pattern) {
        if group_cd = $~[1]
          if subgroup_cd = $~[2]
            if product_cd = $~[3]
              args = [:migel_product, group_cd + subgroup_cd + product_cd.gsub('.','')]
            else
              args = [:migel_subgroup, group_cd + subgroup_cd]
            end
          else
            args = [:migel_group, group_cd]
          end
        end
        '<a class="list" href="' << @lookandfeel._event_url(:migel_search, args) <<
          '">' << $~[0] << '</a>'
      }
    end
    value
  end
  def group(model)
    pointer_link(model.group, :migel_group)
  end
  def limitation_text(model)
    text = model.limitation_text.to_s.force_encoding('utf-8')
    description(text, :limitation_text)
  end
  def subgroup(model)
    pointer_link(model.subgroup, :migel_subgroup)
  end
  def pointer_link(model, key)
    link = PointerLink.new(:to_s, model, @session, self)
    link.value = model.send(@session.language).to_s.force_encoding('utf-8')
    event = :migel_search
    code = model.migel_code.to_s.force_encoding('utf-8')
    link.href = @lookandfeel._event_url(event, {key => code.delete('.')})
    link
  end
  def product_text(model)
    text = model.product_text.to_s.force_encoding('utf-8')
    description(text, :product_text)
  end
  def migel_code(model)
    code = model.migel_code.to_s.force_encoding('utf-8')
    if items = model.items and !items.empty?
      link = PointerLink.new(:to_s, model, @session, self)
      link.value = code
      link.href = @lookandfeel._event_url(:migel_search, {:migel_code => code.gsub(/\./, '')})
      link
    else
      value = HtmlGrid::Value.new(:to_s, model, @session)
      value.value = code
      value
    end
  end
end
class ProductComposite < HtmlGrid::Composite
  CSS_CLASS = 'composite'
  COMPONENTS = {
    [0,0] => 'migel_product',
    [0,1] => ProductInnerComposite,
    [0,2] => :accessories,
  }
  CSS_MAP = {
    [0,0] => 'th',
    [0,2] => 'list',
  }
  DEFAULT_CLASS = HtmlGrid::Value
  LEGACY_INTERFACE = false
  def accessories(model)
    if acc = model.accessories and !acc.empty?
      AccessoryList.new(acc, @session, self)
    elsif products = model.products and prods = products.select{|pro| pro.ean_code != nil and pro.status != 'I'} \
      and !prods.empty?
      AccessoryOfList.new(prods, @session, self)
    end
  end
end
class PointerSteps < ODDB::View::PointerSteps
  def pointer_descr(model, session=@session)
    event = :migel_search
    link = PointerLink.new(:pointer_descr, model, @session, self)
    if model.is_a?(DRbObject)
      # This is the case where Product instance comes from migel DRb server
      # DRbObject is acutally Migel::Model::Group, Subgroup class. see lib/migel/model/migelid.rb in migel project.
      code = model.migel_code.to_s.force_encoding('utf-8')
      key = case code.length
            when 2
              :migel_group
            when 5
              :migel_subgroup
            else
              :migel_product
            end
    elsif model.is_a?(ODDB::Migel::Group)
      key = :migel_group
    elsif model.is_a?(ODDB::Migel::Subgroup)
      key = :migel_subgroup
    elsif model.is_a?(ODDB::Migel::Product)
      key = :migel_product
    end
    link.href = @lookandfeel._event_url(event, {key => code.delete('.')})
    link
  end
end
class Product < View::PrivateTemplate
  CONTENT = ProductComposite
  SNAPBACK_EVENT = :result
  def backtracking(model, session=@session)
    ODDB::View::Migel::PointerSteps.new(model, @session, self)
  end
  def meta_tags(context)
    content = @model.name.send(@session.language).force_encoding('utf-8')
    res = super << context.meta('name' => 'title', 'content' => content)
    if text = @model.migelid_text
      content = text.send(@session.language).to_s.force_encoding('utf-8')
      res << context.meta('name' => 'description', 'content' => content)
    end
    res
  end
end
    end
  end
end
