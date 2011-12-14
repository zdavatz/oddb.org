#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::ResultList -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::ResultList -- oddb.org -- 03.03.2003 -- aschrafl@ywesee.com

require 'htmlgrid/list'
require 'htmlgrid/value'
require 'htmlgrid/datevalue'
require 'htmlgrid/popuplink'
require 'htmlgrid/urllink'
require 'model/package'
require 'view/additional_information'
require 'view/pointervalue'
require 'view/publictemplate'
require 'view/dataformat'
require 'view/resultcolors'
require 'view/descriptionvalue'
require 'view/lookandfeel_components'
require 'sbsm/user'

module HtmlGrid
	class List
		BACKGROUND_SUFFIX = ' bg'
	end
end
module ODDB
	module View
		module Drugs
class User < SBSM::KnownUser; end
class UnknownUser < SBSM::UnknownUser; end
class RootUser < View::Drugs::User; end
class CompanyUser < View::Drugs::User; end
class AtcHeader < HtmlGrid::Composite
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0,0] => :atc_description,
		[0,0,2] => :atc_ddd_link,
		[1,0]   => :pages,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2]	=>	'atc list',
	}
  LEGACY_INTERFACE = false
	def init
		if(@session.allowed?('edit', 'org.oddb.model.!atc_class.*'))
			components.store([0,0,1], :edit)
		end
    if(@model.overflow? \
       && @session.cookie_set_or_get(:resultview) == "atc" \
       && @session.persistent_user_input(:code) == @model.code)
      @css_map = {
        [0,0,2] => 'migel-group list'
      }
    end
		super
	end
	def atc_description(model, session=@session)
    code = model.code
    link = HtmlGrid::Link.new(code, model, @session, self)
    link.value = [
			super,
			model.package_count,
			@lookandfeel.lookup(:products),
			nil,
		].join('&nbsp;')
    if(model.overflow?)
      args = []
      if(@session.persistent_user_input(:code) == code)
        args = [ :search_query, code ]
      else
        args = [
          :search_query, @session.persistent_user_input(:search_query).gsub('/', '%2F'),
          :search_type, @session.persistent_user_input(:search_type),	
          :code, code
        ]
      end
      link.css_class = 'list'
      link.href = @lookandfeel._event_url(:search, args, code)
    end
    link
	end
	def edit(model, session=@session)
		link = View::PointerLink.new(:code, model, session, self)
		link.value = @lookandfeel.lookup(:edit_atc_class) + "&nbsp;"
		link.attributes['class'] = 'small'
		link.href = @lookandfeel._event_url(:atc_class, {:atc_code => model.code})
		link
	end
	def pages(model, session=@session)
		state = @session.state
		if(@session.cookie_set_or_get(:resultview) == "pages" \
       && state.respond_to?(:pages) \
			 && (pages = state.pages) \
			 && pages.size > 1)
			args = {
				:search_query => @session.persistent_user_input(:search_query).gsub('/', '%2F'),
				:search_type => @session.persistent_user_input(:search_type),	
			}
			View::Pager.new(pages, @session, self, :search, args)
		end
	end
end
class ResultList < HtmlGrid::List
	include DataFormat
	include View::ResultColors
	include View::AdditionalInformation
  include View::LookandfeelComponents
	COMPONENTS = {}	
	REVERSE_MAP = {
		:company_name			=> false,
		:most_precise_dose=> false,
		:dsp							=> false,
		:galenic_form			=> false,
		:ikscat						=> false,
		:name_base				=> false,
		:price_exfactory	=> false,
		:price_public			=> false,
		:registration_date=> true,
		:size							=> false,
		:substances				=> true,
	}
	CSS_MAP = {}
	CSS_KEYMAP = {
		:active_agents			=>	'list italic',
		:comarketing        =>	'list',
		:company_name				=>	'list italic',
		:comparable_size		=>	'list right',
		:complementary_type	=>	'list',
		:compositions    		=>	'list italic',
		:ddd_price					=>	'list bold right',
		:deductible					=>	'list bold right',
		:fachinfo						=>	'list',
		:feedback						=>	'list right',
		:galenic_form				=>	'list',
		:google_search			=>	'list right',
		:ikscat							=>	'list italic',
		:limitation_text		=>	'list',
		:minifi  						=>	'list',
		:most_precise_dose	=>	'list right',
		:name_base					=>	'list big',
		:narcotic						=>	'list',
		:notify							=>	'list right',
		:patent             =>	'list',
		:patinfo						=>	'list',
		:price_exfactory		=>	'list right',
		:price_public				=>	'list pubprice',
		:registration_date	=>	'list italic',
		:substances					=>	'list italic',
    :twitter_share      =>  'list right',
		'nbsp'							=>	'list',
	}
	CSS_HEAD_KEYMAP = {
		:active_agents			=>	'th',
		:company_name				=>	'th',
		:comparable_size		=>	'th right',
		:complementary_type	=>	'th',
		:compositions 			=>	'th',
		:ddd_price					=>	'th right',
		:deductible					=>	'th right',
		:fachinfo						=>	'th',
		:feedback						=>	'th right',
		:galenic_form				=>	'th',
		:google_search			=>	'th right',
		:ikscat							=>	'th',
		:limitation_text		=>	'th',
		:minifi  						=>	'th',
		:most_precise_dose	=>	'th right',
		:name_base					=>	'th',
		:narcotic						=>	'th',
		:notify							=>	'th right',
		:patinfo						=>	'th',
		:price_exfactory		=>	'th right',
		:price_public				=>	'th right',
		:registration_date	=>	'th',
		:substances					=>	'th',
    :twitter_share      =>  'th',
    'nbsp'							=>	'th',
	}
	CSS_HEAD_MAP = {}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	SORT_DEFAULT = nil
	SUBHEADER = View::Drugs::AtcHeader
	SYMBOL_MAP = {
		:galenic_form				=>	View::DescriptionValue,
		:ikskey							=>	View::PointerLink,
	}	
	LOOKANDFEEL_MAP = {
		:limitation_text	=>	:ltext,
	}
	def init
		reorganize_components(:result_list_components)
		super
	end
=begin
  def price_exfactory(model, session)
    'price_exfactory'
  end
  def price_public(model, session)
    'price_public'
  end
=end
	def active_agents(model, session=@session)
		link = HtmlGrid::Link.new(:show, model, session, self)
		link.href = @lookandfeel._event_url(:show, {:pointer => model.pointer})
		if model.active_agents.size > 1
			link.set_attribute('title', model.active_agents.join(', '))
			link.value = @lookandfeel.lookup(:active_agents, model.active_agents.size)
		else
			link.value = model.active_agents.to_s
		end
		link
	end
	def compose_list(model=@model, offset=[0,0])
    if(model.respond_to?(:overflow?) && model.overflow?)
      x, y, = offset
      half = full_colspan / 2
      @grid.add(explain_atc(model), x, y)
      @grid.add_style("list migel-group", x, y)
      @grid.set_colspan(x, y, half)
      @grid.add(resultview_switch(model), half, y)
      @grid.add_style("list migel-group right", half, y)
      @grid.set_colspan(half, y, full_colspan - half)
      offset = resolve_offset(offset, self::class::OFFSET_STEP)
    end
    code = @session.persistent_user_input(:code)
    model.each { |atc|
      compose_subheader(atc, offset)
      offset = resolve_offset(offset, self::class::OFFSET_STEP)
      if(show_packages? || code == atc.code)
        packages = atc.packages
        super(packages, offset)
        offset[1] += packages.size
      end
    }
	end
	def compose_subheader(atc, offset)
		subheader = self::class::SUBHEADER.new(atc, @session, self)
		@grid.add(subheader, *offset)
		@grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
	end
  def explain_atc(model)
    link = HtmlGrid::Link.new(:explain_atc, model, @session, self)
    link.href = @lookandfeel.lookup(:explain_atc_url)
    link.css_class = 'list bold'
    link
  end
  def galenic_form(model, session=@session)
    lang = @session.language
    model.galenic_forms.collect { |gf| gf.send lang }.compact.join(' / ')
  end
	def fachinfo(model, session=@session)
		super(model, session, 'square important infos')
	end	
	def registration_date(model, session=@session)
		span = HtmlGrid::Span.new(model, @session, self)
		span.value = HtmlGrid::DateValue.new(:registration_date, 
																				 model, @session, self)
		if(exp = (model.inactive_date || model.expiration_date))
			span.set_attribute('title', 
												 @lookandfeel.lookup(:valid_until, @lookandfeel.format_date(exp)))
		end
		span
	end
  def resultview_switch(model, session=@session)
    current = @session.cookie_set_or_get(:resultview)
    switched = (current == 'pages' ? 'atc' : 'pages')
    args = {
      :search_query => @session.persistent_user_input(:search_query).gsub('/', '%2F'),
      :search_type => @session.persistent_user_input(:search_type),	
      :resultview  => switched,
    }
    link = HtmlGrid::Link.new("rv_#{switched}", model, @session, self)
    if @lookandfeel.disabled?(:best_result)
      link.href = @lookandfeel._event_url(:search, args)
    else
      link.href = @lookandfeel._event_url(:search, args, "best_result")
    end
    link.css_class = "list bold"
    link
  end
  def show_packages?
    !(@model.respond_to?(:overflow?) && @model.overflow?) \
      || @session.cookie_set_or_get(:resultview) == "pages"
  end
	def substances(model, session=@session)
		link = HtmlGrid::Link.new(:show, model, session, self)
    if reg = model.iksnr and seq = model.seqnr and pac = model.ikscd
		  link.href = @lookandfeel._event_url(:show, [:reg, reg, :seq, seq, :pack, pac])
    else
		  link.href = @lookandfeel._event_url(:show, {:pointer => model.pointer})
    end
		if (model.active_agents.size > 1)
			#txt = HtmlGrid::Component.new(model, session, self)
			link.set_attribute('title', model.active_agents.join(', '))
			link.value = @lookandfeel.lookup(:active_agents, model.active_agents.size)
		else
			link.value = model.substances.first.to_s
		end
		link
	end
end
		end
	end
end
