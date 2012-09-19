#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Compare -- oddb.org -- 21.09.2012 -- yasaka@ywesee.com
# ODDB::View::Drugs::Compare -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com 
# ODDB::View::Drugs::Compare -- oddb.org -- 20.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/datevalue'
require 'htmlgrid/list'
require 'view/drugs/privatetemplate'
require 'view/resultcolors'
require 'view/resultfoot'
require 'view/dataformat'
require 'view/sponsorhead'

module ODDB
	module View
		module Drugs
class CompareList < HtmlGrid::List
	include DataFormat
	include View::ResultColors
	include View::AdditionalInformation
	COMPONENTS = {}
	CSS_CLASS = 'composite'
  CSS_KEYMAP = {
    :active_agents     => 'list italic',
    :company_name      => 'list italic',
    :comparable_size   => 'list',
    :compositions      => 'list italic',
    :ddd_price         => 'list right',
    :deductible        => 'list right',
    :prescription      => 'list',
    :fachinfo          => 'list',
    :ikscat            => 'list italic',
    :most_precise_dose => 'list right',
    :name_base         => 'list big',
    :patinfo           => 'list',
    :price_difference  => 'list bold right',
    :price_public      => 'list pubprice',
  }
	CSS_HEAD_KEYMAP = {
		:active_agents     => 'th',
		:company_name			 => 'th',
		:comparable_size	 => 'th',
		:compositions      =>	'th',
		:ddd_price				 => 'th right',
		:deductible				 => 'th right',
    :fachinfo          => 'th',
		:ikscat						 => 'th',
		:most_precise_dose => 'th right',
		:name_base				 => 'th',
    :patinfo           => 'th',
		:price_difference	 => 'th right',
		:price_public			 => 'th right',
	}
	CSS_HEAD_MAP = {}
	CSS_MAP = {}
	DEFAULT_CLASS = HtmlGrid::Value
	SORT_DEFAULT = nil
	SORT_HEADER = false
	SORT_REVERSE = false
	SYMBOL_MAP = {
		:registration_date	=>	HtmlGrid::DateValue,
	}
	def init
		reorganize_components
		super
	end
	def reorganize_components
		@components = @lookandfeel.compare_list_components
		@css_map = {}
		@css_head_map = {}
		@components.each { |key, val|
			if(klass = self::class::CSS_KEYMAP[val])
				@css_map.store(key, klass)
				@css_head_map.store(key, self::class::CSS_HEAD_KEYMAP[val] || 'th')
			end
		}
	end
	def active_agents(model, session)
		model.active_agents.join(',<br>')
	end
	def compose_empty_list(offset)
		package_line(offset)
		text = @lookandfeel.lookup(:no_comparables)
		offset = resolve_offset(offset, self::class::OFFSET_STEP)
		@grid.add(text, *offset)
		@grid.add_style('list', *offset)
		@grid.set_colspan(*offset)
	end
	def compose_list(model=@model, offset=[0,0])
		package_line(offset)
		offset = resolve_offset(offset, self::class::OFFSET_STEP)
		super(model.comparables, offset)
	end
	def package_line(offset)
		_compose(@model.package, offset) if(@model.respond_to? :package)
	end
	def price_difference(model, session)
		if(diff = model.price_difference)
			sprintf('%+d%', diff*100.0)
		end
	end
  def sort_model
    if((@session.event != :sort) && (block = @lookandfeel.comparison_sorter))
      @model.sort_by!(&block)
    end
  end
end
class CompareComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0] => CompareList,
		[0,1] => View::ResultFoot,
	}
	CSS_MAP = {
		[0,1]	=>	'explain list',
	}
end
module InsertBackbutton
  def reorganize_components
    super
    components.store([1,1,0], :print)
    idx = components.index(:backtracking)
    if(@lookandfeel.enabled?(:breadcrumbs))
      css_map.store(idx, 'breadcrumbs')
    end
    if(@lookandfeel.enabled?(:compare_backbutton, false))
      components.delete(idx)
      x,y = idx
      components.store([x,y,0], :backtracking)
      components.store([x,y,1], :back_button)
      css_map.store(idx, 'snapback')
    end
  end
  def back_button(model, session=@session)
    button = HtmlGrid::Button.new(:compare_backbutton, model, @session, self)
    event, url = snapback
    button.set_attribute("onclick", "document.location.href='#{url}'")
    button.css_class = "button"
    button
  end
  def backtracking(model, session=@session)
    if(@lookandfeel.enabled?(:breadcrumbs))
      breadcrumbs = []
      level = 3
      dv = HtmlGrid::Span.new(model, @session, self)
      dv.css_class = "breadcrumb"
      dv.value = "&lt;"
      if @lookandfeel.enabled?(:home)
        span1 = HtmlGrid::Span.new(model, @session, self)
        span1.css_class = "breadcrumb-#{level} bold"
        level -= 1
        link1 = HtmlGrid::Link.new(:back_to_home, model, @session, self)
        link1.href = @lookandfeel._event_url(:home)
        link1.css_class = "list"
        span1.value = link1
        breadcrumbs.push span1, dv
      end
      span2 = HtmlGrid::Span.new(model, @session, self)
      span2.css_class = "breadcrumb-#{level}"
      level -= 1
      link2 = HtmlGrid::Link.new(:result, model, @session, self)
      link2.css_class = "list"
      query = @session.persistent_user_input(:search_query)
      query = model.name_base if model.respond_to?(:name_base) && (query.is_a?(SBSM::InvalidDataError) || query.nil?)
      if query and !query.is_a?(SBSM::InvalidDataError)
        args = [
          :zone, :drugs, :search_query, query.gsub('/', '%2F'), :search_type,
          @session.persistent_user_input(:search_type) || 'st_oddb',
        ]
        link2.href = @lookandfeel._event_url(:search, args)
        link2.value = @lookandfeel.lookup(:back_to_list_for, query)
      end
      span2.value = link2
      span3 = HtmlGrid::Span.new(model, @session, self)
      span3.css_class = "breadcrumb-#{level}"
      if(respond_to?(:pointer_descr))
        span3.value = self.send(:pointer_descr, model)
      elsif(model.respond_to? :pointer_descr)
        span3.value = model.pointer_descr
      end
      breadcrumbs.push span2, dv, span3
    else
      super
    end
  end
  def print(model, session=@session)
    link = HtmlGrid::Link.new(:print, model, @session, self)
    link.set_attribute('onClick', 'window.print();')
    link.href = ""
    link
  end
end
class Compare < PrivateTemplate
	include View::SponsorMethods
  include InsertBackbutton
	CONTENT = CompareComposite
	SNAPBACK_EVENT = :result
end
class EmptyCompareComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	'compare_title_no_atc',
		[0,1]		=>	:compare_desc0_no_atc,
		[0,2,0]	=>	:compare_desc1_no_atc,
		[0,2,1]	=>	:ywesee_contact_email,
		[0,2,2]	=>	'point',
	}
	CSS_MAP = {
		[0,0]			=>	'th',
		[0,1,1,2]	=>	'list',
	}
	CSS_CLASS = 'composite'
	def compare_desc0_no_atc(model, session)
		query = model.package.name_base
		@lookandfeel.lookup(:compare_desc0_no_atc, query)
	end
	def compare_desc1_no_atc(model, session)
		query = model.package.name_base
		@lookandfeel.lookup(:compare_desc1_no_atc, query)
	end
	def ywesee_contact_email(model, session)
		link = HtmlGrid::Link.new(:ywesee_contact_email, model, session, self)
		link.href = @lookandfeel.lookup(:ywesee_contact_href)
		link.attributes['class'] = 'text'
		link
	end
end
class EmptyCompare < PrivateTemplate
  include InsertBackbutton
	CONTENT = View::Drugs::EmptyCompareComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
