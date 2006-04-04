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
		[0,0] => :atc_description,
		[0,0,1] => :atc_ddd_link,
		[1,0] => :pages,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'atc-result',
	}
	def init
		if(@session.user.is_a? RootUser)
			components.store([0,0,0], :edit)
		end
		super
	end
	def atc_ddd_link(atc, session)
		while(atc && !atc.has_ddd? && (code = atc.parent_code))
			atc = session.app.atc_class(code)
		end
		super(atc, session)
	end
	def atc_description(model, session)
		[
			super,
			model.package_count,
			@lookandfeel.lookup(:products),
			nil,
		].join('&nbsp;')
	end
	def edit(model, session)
		link = View::PointerLink.new(:code, model, session, self)
		link.value = @lookandfeel.lookup(:edit_atc_class) + "&nbsp;"
		link.attributes['class'] = 'small'
		link
	end
	def pages(model, session)
		state = @session.state
		if(state.respond_to?(:pages) \
			&& (pages = state.pages) \
			&& pages.size > 1)
			args = {
				:search_query => @session.persistent_user_input(:search_query),	
				:search_type => @session.persistent_user_input(:search_type),	
			}
			View::Pager.new(pages, session, self, :search, args)
		end
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
		:limitation_text		=>	'result-infos',
		:fachinfo						=>	'result-infos',
		:patinfo						=>	'result-infos',
		:narcotic						=>	'result-infos',
		:complementary_type	=>	'result-infos',
		:name_base					=>	'result-big',
		:galenic_form				=>	'result',
		:most_precise_dose	=>	'result-r',
		:comparable_size		=>	'result-r',
		:price_exfactory		=>	'result-r',
		:price_public				=>	'result-pubprice',
		:deductible					=>	'result-r',
		:substances					=>	'result-i',
		:company_name				=>	'result-i',
		:ikscat							=>	'result-i',
		:registration_date	=>	'result-i',
		:feedback						=>	'result-b-r',
		:google_search			=>	'result-b-r',
		:notify							=>	'result-b-r',
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
				th_klass = case klass
									 when 'result-pubprice', /r$/
										 'th-r'
									 else
										 'th'
									 end
				@css_head_map.store(key, th_klass)
			end
		}
	end
	def comparable_size(model, session=@session)
		HtmlGrid::Value.new(:size, model, session, self)
	end
	def complementary_type(model, session=@session)
		if(model.generic_type == :complementary \
			&& (ctype = model.complementary_type))
			square = HtmlGrid::Span.new(model, @session, self)
			square.value = @lookandfeel.lookup("c_type_#{ctype}")
			square.set_attribute('title', @lookandfeel.lookup(ctype))
			square.css_class = "square #{ctype}"
			square
		end
	end
	def compose_list(model=@model, offset=[0,0])
		model.each { |atc|	
			compose_subheader(atc, offset)
			offset = resolve_offset(offset, self::class::OFFSET_STEP)
			packages = atc.packages
			super(packages, offset)
			offset[1] += packages.size
		}
	end
	def compose_subheader(atc, offset)
		subheader = self::class::SUBHEADER.new(atc, @session, self)
		@grid.add(subheader, *offset)
		@grid.add_style('result-atc', *offset)
		@grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
	end
	def fachinfo(model, session=@session)
		super(model, session, 'important-infos')
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
