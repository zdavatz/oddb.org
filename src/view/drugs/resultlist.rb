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
require 'view/template'
require 'sbsm/user'

module ODDB
	module View
		module Drugs
class User < SBSM::KnownUser; end
class UnknownUser < SBSM::UnknownUser; end
class AdminUser < View::Drugs::User; end
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
		if(@session.user.is_a? AdminUser)
			components.store([0,0,0], :edit)
		end
		super
	end
	def atc_description(atc, session)
		atc_descr = if(descr = atc.description(@lookandfeel.language))
			descr.dup.to_s << ' (' << atc.code << ')' 
		else
			atc.code
		end
		text = [
			atc_descr,
			atc.package_count,
			@lookandfeel.lookup(:products),
			nil,
		].join('&nbsp;')
		text
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
			pager = View::Pager.new(pages, session, self)
		end
		pager
	end
end
class ResultList < HtmlGrid::List
	include DataFormat
	include View::ResultColors
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0,0]	=>	'result_item_start',
		[0,0,1]	=>	:name_base,
		[0,0,2]	=>	'result_item_end',
		[1,0]		=>	:galenic_form,
		[2,0]		=>	:most_precise_dose,
		[3,0]		=>	:comparable_size,
		[4,0]		=>	:price_exfactory,
		[5,0]		=>	:price_public,
		[6,0]		=>	:substances,
		[7,0]		=>	:company_name,
		[8,0]		=>	:ikscat,
		[9,0]		=>	:registration_date,
		[10,0]	=>	:fachinfo,
		[11,0]	=>  :patinfo,
		[12,0]	=>	:limitation_text,
		[13,0]	=>  :feedback,
	}	
	REVERSE_MAP = {
		:company_name			=> false,
		:dose							=> false,
		:galenic_form			=> false,
		:ikscat						=> false,
		:name_base				=> false,
		:price_exfactory	=> false,
		:price_public			=> false,
		:registration_date=> true,
		:size							=> false,
		:substances				=> true,
	}
		BACKGROUND_SUFFIX = ' bg'
	CSS_MAP = {
		[0,0]	=>	'result big',
		[1,0]	=>	'result',
		[2,0]	=>	'result right',
		[3,0]	=>	'result right',
		[4,0]	=>	'result right',
		[5,0]	=>	'result bold right',
		[6,0]	=>	'result italic',
		[7,0]	=>	'result italic',
		[8,0]	=>	'result italic',
		[9,0]	=>	'result italic',
		[10,0]	=>	'result bold right',
		[11,0] =>  'result bold right',
		[12,0]	=>	'result bold right',
		[12,0]	=>	'result bold right',
	}
	CSS_HEAD_MAP = {
		[0,0,1] =>	'th',
		[1,0] =>	'th',
		[2,0]	=>	'th-r',
		[3,0]	=>	'th-r',
		[4,0]	=>	'th-r',
		[5,0]	=>	'th-pad-r',
		[6,0] =>	'th',
		[7,0] =>	'th',
		[8,0]	=>	'th',
		[9,0]	=>	'th',
		[10,0]=>	'th-r',
		[11,0]=>	'th-r',
		[12,0]=>	'th-r',
	}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	#SORT_AUTO = true
	SORT_DEFAULT = nil
	SUBHEADER = View::Drugs::AtcHeader
	#SORT_REVERSE = true
	SYMBOL_MAP = {
		:galenic_form				=>	View::DescriptionValue,
		:registration_date	=>	HtmlGrid::DateValue,
		:ikskey							=>	View::PointerLink,
	}	
	def compose_subheader(atc, offset)
		subheader = self::class::SUBHEADER.new(atc, @session, self)
		@grid.add(subheader, *offset)
		@grid.add_style('result-atc', *offset)
		@grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
	end
	def company_name(model, session)
		comp = model.company
		return if comp.nil?
		if(@lookandfeel.enabled?(:powerlink, false) && comp.powerlink)
			link = HtmlGrid::HttpLink.new(:name, model.company, session, self)
			link.href = @lookandfeel.event_url(:powerlink, {'pointer'=>comp.pointer})
			link.set_attribute("class", "powerlink")
			link
		elsif(@lookandfeel.enabled?(:companylist) \
			&& model.company.listed?)
			View::PointerLink.new(:name, model.company, session, self)
		else
			HtmlGrid::Value.new(:name, model.company, session, self)
		end
	end
	def comparable_size(model, session)
		HtmlGrid::Value.new(:size, model, session, self)
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
	def fachinfo(model, session)
		super(model, session, 'important-infos')
	end
	def ikscat(model, session)
		txt = HtmlGrid::Component.new(model, session, self)
		txt.value = [
			(cat = model.ikscat),
			(@lookandfeel.lookup(:sl) unless (sl = model.sl_entry).nil?),
		].compact.join('&nbsp;/&nbsp;')
		title = [
			(@lookandfeel.lookup(('ikscat_'+(cat.downcase)).intern) unless cat.nil?),
			(@lookandfeel.lookup(:sl_list) unless sl.nil?),
		].compact.join('&nbsp;/&nbsp;')
		txt.set_attribute('title', title)
		txt
	end
	def name_base(model, session)
		link = HtmlGrid::PopupLink.new(:compare, model, session, self)
		link.href = @lookandfeel.event_url(:compare, {'pointer'=>model.pointer})
		link.value = model.name_base
		link.set_attribute('class', 'result big' << resolve_suffix(model))
		link.set_attribute('title', @lookandfeel.lookup(:ean_code, model.barcode))
		link
	end
	def substances(model, session)
		if (model.active_agents.size > 1)
			txt = HtmlGrid::Component.new(model, session, self)
			txt.set_attribute('title', model.active_agents.join(', '))
			txt.value = @lookandfeel.lookup(:active_agents, model.active_agents.size)
			txt
		else
			model.substances.first.to_s
		end
	end
end
		end
	end
end
