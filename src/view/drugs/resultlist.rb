#!/usr/bin/env ruby
# View::Drugs::ResultList -- oddb -- 03.03.2003 -- aschrafl@ywesee.com

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
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'atc',
	}
	def init
		if(@session.user.allowed?('edit', 'org.oddb.model.!atc_class.*'))
			components.store([0,0,1], :edit)
		end
		super
	end
	def atc_ddd_link(atc, session)
		unless(@lookandfeel.disabled?(:atc_ddd))
			while(atc && !atc.has_ddd? && (code = atc.parent_code))
				atc = session.app.atc_class(code)
			end
			super(atc, session)
		end
	end
	def atc_description(model, session)
    code = model.code
    link = HtmlGrid::Link.new(code, model, @session, self)
    link.value = [
			super,
			model.package_count,
			@lookandfeel.lookup(:products),
			nil,
		].join('&nbsp;')
    if(@session.state.overflow?)
      args = []
      if(@session.persistent_user_input(:code) == code)
        link.css_class = 'atclink'
        args = [ :search_query, code ]
      else
        args = [
          :search_query, @session.persistent_user_input(:search_query),	
          :search_type, @session.persistent_user_input(:search_type),	
          :code, code
        ]
        link.css_class = 'list'
      end
      link.href = @lookandfeel._event_url(:search, args, code)
    end
    link
	end
	def edit(model, session)
		link = View::PointerLink.new(:code, model, session, self)
		link.value = @lookandfeel.lookup(:edit_atc_class) + "&nbsp;"
		link.attributes['class'] = 'small'
		link
	end
end
class ResultList < HtmlGrid::List
	include DataFormat
	include View::ResultColors
	include View::AdditionalInformation
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
		:limitation_text		=>	'list',
		:fachinfo						=>	'list',
		:patinfo						=>	'list',
		:narcotic						=>	'list',
		:complementary_type	=>	'list',
		:name_base					=>	'list big',
		:galenic_form				=>	'list',
		:most_precise_dose	=>	'list right',
		:comparable_size		=>	'list right',
		:price_exfactory		=>	'list right',
		:price_public				=>	'list pubprice',
		:deductible					=>	'list bold right',
		:substances					=>	'list italic',
		:company_name				=>	'list italic',
		:ikscat							=>	'list italic',
		:ddd_price					=>	'list bold right',
		:registration_date	=>	'list italic',
		:feedback						=>	'list right',
		:google_search			=>	'list right',
		:notify							=>	'list right',
		'nbsp'							=>	'list',
	}
	CSS_HEAD_KEYMAP = {
		:active_agents			=>	'th',
		:limitation_text		=>	'th',
		:fachinfo						=>	'th',
		:patinfo						=>	'th',
		:narcotic						=>	'th',
		:complementary_type	=>	'th',
		:name_base					=>	'th',
		:galenic_form				=>	'th',
		:most_precise_dose	=>	'th right',
		:comparable_size		=>	'th right',
		:price_exfactory		=>	'th right',
		:price_public				=>	'th right',
		:deductible					=>	'th right',
		:substances					=>	'th',
		:company_name				=>	'th',
		:ikscat							=>	'th',
		:ddd_price					=>	'th right',
		:registration_date	=>	'th',
		:feedback						=>	'th right',
		:google_search			=>	'th right',
		:notify							=>	'th right',
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
		reorganize_components
		super
	end
	def reorganize_components
		@components = @lookandfeel.result_list_components
		@css_map = {}
		@css_head_map = {}
		@components.each { |key, val|
			if(klass = self::class::CSS_KEYMAP[val])
				@css_map.store(key, klass)
				@css_head_map.store(key, self::class::CSS_HEAD_KEYMAP[val] || 'th')
			end
		}
	end
	def active_agents(model, session=@session)
		link = HtmlGrid::Link.new(:show, model, session, self)
		link.href = @lookandfeel._event_url(:show, {:pointer => model.pointer})
		if (model.active_agents.size > 1)
			link.set_attribute('title', model.active_agents.join(', '))
			link.value = @lookandfeel.lookup(:active_agents, model.active_agents.size)
		else
			link.value = model.active_agents.to_s
		end
		link
	end
	def comparable_size(model, session=@session)
		HtmlGrid::Value.new(:size, model, session, self)
	end
	def compose_list(model=@model, offset=[0,0])
    display_all = !@session.state.overflow?
    code = @session.persistent_user_input(:code)
    model.each { |atc|
      compose_subheader(atc, offset)
      offset = resolve_offset(offset, self::class::OFFSET_STEP)
      if(display_all || code == atc.code)
        packages = atc.packages
        super(packages, offset)
        offset[1] += packages.size
      end
    }
	end
	def compose_subheader(atc, offset)
		subheader = self::class::SUBHEADER.new(atc, @session, self)
		@grid.add(subheader, *offset)
		@grid.add_style('list atc', *offset)
		@grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
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
	def substances(model, session=@session)
		link = HtmlGrid::Link.new(:show, model, session, self)
		link.href = @lookandfeel._event_url(:show, {:pointer => model.pointer})
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
