#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Package -- oddb -- 25.12.2012 -- yasaka@ywesee.com
# ODDB::View::Drugs::Package -- oddb -- 15.02.2005 -- hwyss@ywesee.com

require 'view/admin/swissmedic_source'
require 'view/admin/sequence'
require 'view/drugs/privatetemplate'
require 'view/drugs/sequence'
require 'view/additional_information'
require 'view/facebook'
require 'htmlgrid/booleanvalue'

module ODDB
	module View
		module Drugs
class CompositionList < HtmlGrid::DivList
  include PartSize
  COMPONENTS = { [0,0] => :composition }
  LABELS = false
  OFFSET_STEP = [1,0]
  OMIT_HEADER = true
  def composition(model)
    div = HtmlGrid::Div.new(model, @session, self)
    div.css_class = 'galenic-form'
    size = part_size(model)
    if (comp = model.composition) && (label = comp.label)
      size = "#{label}) #{size}"
    end
    div.value = size
    [ div, View::Admin::ActiveAgents.new(model.active_agents, @session, self)]
  end
end
class Parts < View::Admin::Compositions
  COMPONENTS = { [0,0] => CompositionList }
end
class PackageInnerComposite < HtmlGrid::Composite
	include DataFormat
	include View::AdditionalInformation
  COMPONENTS = {
    # left
    [0,0,0] => :ikskey,
    [1,0,0] => "&nbsp;",
    [1,0,1] => :comarketing,
    [2,0]   => :registration_holder,
    [0,1]   => :name,
    [0,2]   => :sl_generic_type,
    [0,3,0] => :atc_class,
    [1,4,1] => :atc_ddd_link,
    [0,4]   => :who,
    [0,5]   => :index_therapeuticus,
    [0,6]   => :ith_swissmedic,
    [0,7]   => :ikscat,
    [0,8]   => :sl_entry,
    [0,9]   => :price_exfactory,
    [0,10]  => :deductible,
    [0,11]  => :pharmacode,
    # right
    [2,1]   => :registration_date,
    [2,2]   => :sequence_date,
    [2,3]   => :revision_date,
    [2,4]   => :expiration_date,
    [2,5]   => :size,
    [2,6]   => :descr,
    [2,8]   => :indication,
    [2,10]  => :price_public,
  }
	CSS_MAP = {
		[0,0,4] => 'list',
		[0,1,4] => 'list',
		[0,2,4] => 'list',
		[0,3,4] => 'list',
		[0,4,4] => 'list',
		[0,5,4] => 'list',
		[0,6,4] => 'list',
		[0,7,4] => 'list',
		[0,8,4] => 'list',
		[0,9,4] => 'list',
		[0,10,4] => 'list',
		[0,11,4] => 'list',
		[0,12,4] => 'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
  LEGACY_INTERFACE = false
  LOOKANDFEEL_MAP = {
    :descr  =>  :description,
  }
	COLSPAN_MAP = { }
	SYMBOL_MAP = {
		:sl_entry						=>	HtmlGrid::BooleanValue,
		:limitation					=>	HtmlGrid::BooleanValue,
    :barcode_label      =>  HtmlGrid::LabelText,
		:patinfo_label			=>	HtmlGrid::LabelText,
		:fachinfo_label			=>	HtmlGrid::LabelText,
		:feedback_label			=>	HtmlGrid::LabelText,
		:narcotic_label			=>	HtmlGrid::LabelText,
		:registration_date	=>	HtmlGrid::DateValue,
		:revision_date			=>	HtmlGrid::DateValue,
    :sequence_date      =>  HtmlGrid::DateValue,
		:expiration_date		=>	HtmlGrid::DateValue,
	}
  def init
    if(@model.narcotic?)
      components.update(
        [2,12] => :narcotic_label,
        [3,12] => :narcotic
      )
    end
    if(@lookandfeel.enabled?(:feedback))
      components.update(
        [0,11] => :feedback_label,
        [1,11] => :feedback,
        [0,12] => :pharmacode
      )
      css_map.store([0,12,4], 'list')
    end
    if @lookandfeel.enabled?(:show_ean13)
      if components[[0,12]] == :pharmacode
        components.update(
          [0,12] => :barcode_label,
          [1,12] => :barcode,
          [0,13] => :pharmacode
        )
        css_map.store([0,13,4], 'list')
      else
        components.update(
          [0,11] => :barcode_label,
          [1,11] => :barcode,
          [0,12] => :pharmacode
        )
        css_map.store([0,12,4], 'list')
      end
    end
    if(@model.ddd_price)
      components.store([2,11], :ddd_price)
    end
    if(@model.production_science)
      components.store([2,12], :production_science)
    end

    if(@model.sl_entry)
      components.store([2,9], :limitation)
      hash_insert_row(components, [0,10], :introduction_date)
      hash_insert_row(css_map, [0,10,4], 'list')
      if(@model.limitation_text)
        hash_insert_row(components, [0,10], :limitation_text)
        hash_insert_row(css_map, [0,10,4], 'list')
      end
    end
    if(@lookandfeel.enabled?(:fachinfos))
      hash_insert_row(components, [0,9], :fachinfo_label)
      hash_insert_row(css_map, [0,9,4], 'list')
      components.update({
        [1,9] => :fachinfo,
        [2,9] => :patinfo_label,
        [3,9] => :patinfo,
      })
    elsif(@lookandfeel.enabled?(:patinfos))
      hash_insert_row(components, [2,9], :patinfo_label)
      hash_insert_row(css_map, [0,9,4], 'list')
      components.store([3,9], :patinfo)
    end
    if(idx = components.index(:limitation_text))
      css_map.store(idx, 'list top')
      sidx = idx.dup
      sidx[0] += 1
      colspan_map.store(sidx, 3)
    end
    super
  end
	def atc_class(model, session=@session)
		val = HtmlGrid::Value.new(:atc_class, model, @session, self)
		if(atc = model.atc_class)
			val.value = atc_description(atc, @session)
		end
		val
	end
	def atc_ddd_link(model, session=@session)
		if(atc = model.atc_class)
			super(atc, session)
		end
	end
	## ignore AdditionalInformation#ikscat
	def ikscat(model, session=@session)
		HtmlGrid::Value.new(:ikscat, model, @session, self)
	end
  def index_therapeuticus(model, session=@session)
    _index_therapeuticus model, :index_therapeuticus
  end
  def ith_swissmedic(model, session=@session)
    _index_therapeuticus model, :ith_swissmedic
  end
  def _index_therapeuticus(model, key)
    span = HtmlGrid::Span.new(model, @session, self)
    span.value = code = model.send(key)
    span.css_id = "#{key}#{model.ikskey}"
    if code
      ith = nil
      until ith || code.empty?
        ith = IndexTherapeuticus.find_by_code(code)
        code = code.gsub /\d+\.$/u, ''
      end
      if ith
        tooltip = HtmlGrid::Div.new(model, @session, self)
        tooltip.value = ith.send(@session.language) 
        span.dojo_tooltip = tooltip
      end
    end
    span.label = true
    span
  end
  def introduction_date(model, session=@session)
    HtmlGrid::DateValue.new(:introduction_date, model.sl_entry, @session, self)
  end
	def limitation_text(model, session=@session)
    text = HtmlGrid::Div.new(model, @session, self)
    text.label = true
		if(lim = model.limitation_text)
			text.value = lim.send(@session.language)
      text.css_class = "long-text"
		end
    text
	end
	def most_precise_dose(model, session=@session)
		HtmlGrid::Value.new(:most_precise_dose, model, session, self)
	end
  def name(model, session=@session)
    link = HtmlGrid::Link.new(:name, model, @session, self)
    link.value = model.name
    link.label = true
    args = {
      :zone => :drugs, 
      :search_query => model.name_base.gsub('/', '%2F'),
      :search_type => :st_oddb,
    }
    if @lookandfeel.disabled?(:best_result)
      link.href = @lookandfeel._event_url(:search, args)
    else
      link.href = @lookandfeel._event_url(:search, args, "best_result")
    end
    link
  end
  def sl_generic_type(model, session=@session)
    if(key = model.sl_generic_type)
      text = HtmlGrid::Text.new(key, model, session, self)
      text.label = true
      text
    end
  end
	def registration_holder(model, session=@session)
		HtmlGrid::Value.new(:company_name, model, @session, self)
	end
end
class PackageComposite < HtmlGrid::Composite
  include View::Admin::SwissmedicSource
  include View::Facebook
  include View::AdditionalInformation
  COMPONENTS = {
    [0,0] => :package_name,
    [0,1] => View::Drugs::PackageInnerComposite,
    [0,2] => 'composition',
    [0,3] => :composition_text,
    [0,4] => 'th_parts',
    [0,5] => :parts,
    [0,6] => 'th_source',
    [0,7] => :source,
  }
  CSS_CLASS ='composite'
  CSS_MAP = {
    [0,0] => 'th',
    [0,2] => 'subheading',
    [0,3] => 'list',
    [0,4] => 'subheading',
    [0,5] => 'list',
    [0,6] => 'subheading',
    [0,7] => 'list',
  }
  DEFAULT_CLASS = HtmlGrid::Value
  def init
    if seq = @model.sequence and div = seq.division and !div.empty?
      components.store [0,4], 'division'
      components.store [0,5], :division
      components.store [0,6], 'th_part'
      components.store [0,7], :parts
      components.store [0,8], 'th_source'
      components.store [0,9], :source
      css_map.store [0,8], 'subheading'
      css_map.store [0,9], 'list'
    end
    y = components.length + 1
    if @lookandfeel.enabled?(:twitter_share)
      components.store [0,y,0], :twitter_share
      css_map.store [0,y], 'list'
    end
    y = components.length + 1
    if @lookandfeel.enabled?(:facebook_share)
      components.store [0,y,1], :facebook_share
      css_map.store [0,y], 'list spaced'
    end
    super
  end
  def compositions(model, session=@session)
    View::Admin::Compositions.new(model.compositions, @session, self)
  end
  def division(model, session)
    division = nil
    if sequence = model.sequence
      division = sequence.division
    end
    View::Drugs::DivisionComposite.new(division, session, self)
  end
	def package_name(model, session)
		[model.name, model.size].compact.join('&nbsp;-&nbsp;')
	end
  def parts(model, session=@session)
    View::Drugs::Parts.new(model.parts, @session, self)
  end
  def source(model, session=@session)
    val = HtmlGrid::Value.new(:source, model, @session, self)
    val.value = package_source(model) if model
    val
  end
end
class Package < PrivateTemplate
  include PartSize
	CONTENT = View::Drugs::PackageComposite
	SNAPBACK_EVENT = :result
  JAVASCRIPTS = ['bit.ly']
  def meta_tags(context)
    base = @model.name_base
    size = comparable_size(@model)
    fullname = sprintf("%s, %s", base, size)
    res = super << context.meta('name' => 'title', 'content' => fullname)
    if ind = @model.indication
      res << context.meta('name' => 'description',
                          'content' => ind.send(@session.language))
    end
    res
  end
end
		end
	end
end
