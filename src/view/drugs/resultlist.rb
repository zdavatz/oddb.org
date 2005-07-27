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
	COMPONENTS = {
		[0,0]		=>	:limitation_text,
		[1,0]		=>  :fachinfo,
		[2,0]		=>	:patinfo,
		[3,0]		=>	:complementary_type,
		[4,0,0]	=>	'result_item_start',
		[4,0,1]	=>	:name_base,
		[4,0,2]	=>	'result_item_end',
		[5,0]		=>	:galenic_form,
		[6,0]		=>	:most_precise_dose,
		[7,0]		=>	:comparable_size,
		[8,0]		=>	:price_exfactory,
		[9,0]		=>	:price_public,
		[10,0]		=>	:substances,
		[11,0]	=>	:company_name,
		[12,0]	=>	:ikscat,
		[13,0]	=>	:registration_date,
		[14,0]	=>	:feedback,
		[15,0]	=>  :google_search,
		[16,0]	=>	:notify,
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
	CSS_MAP = {
		[1,0,3]	=>	'result-b-r',
		[4,0]		=>	'result-big',
		[5,0]		=>	'result',
		[6,0,3]	=>	'result-r',
		[9,0]		=>	'result-pubprice',
		[10,0,4]	=>	'result-i',
		[14,0,3]=>	'result-b-r',
	}
	CSS_HEAD_MAP = {
		[0,0] =>	'th',
		[1,0] =>	'th',
		[2,0] =>	'th',
		[3,0] =>	'th',
		[4,0,1] =>	'th',
		[5,0]	=>	'th',
		[6,0]	=>	'th-r',
		[7,0]	=>	'th-r',
		[8,0]	=>	'th-r',
		[9,0] =>	'th-r',
		[10,0] =>	'th',
		[11,0]	=>	'th',
		[12,0]	=>	'th',
		[13,0]=>	'th',
		[14,0]=>	'th-r',
		[15,0]=>	'th-r',
		[16,0]=>	'th-r',
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
	LOOKANDFEEL_MAP = {
		:limitation_text	=>	:ltext,
	}
	def breakline(txt, length)
		name = ''
		line = ''
		txt.to_s.split(/(:?[\s-])/).each { |part|
			if((line.length + part.length) > length)
				name << line << '<br>'
				line = part
			else
				line << part
			end
		}
		name << line
	end
	def company_name(model, session)
		if(comp = model.company)
			link = nil
			if(@lookandfeel.enabled?(:powerlink, false) && comp.powerlink)
				link = HtmlGrid::HttpLink.new(:name, comp, session, self)
				link.href = @lookandfeel.event_url(:powerlink, {'pointer'=>comp.pointer})
				link.set_attribute("class", "powerlink")
			elsif(@lookandfeel.enabled?(:companylist) \
				&& comp.listed?)
				link = View::PointerLink.new(:name, comp, session, self)
			else
				link = HtmlGrid::Value.new(:name, comp, session, self)
			end
			link.value = breakline(comp.name, 12)
			link
		end
	end
	def comparable_size(model, session)
		HtmlGrid::Value.new(:size, model, session, self)
	end
	def complementary_type(model, session)
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
	def fachinfo(model, session)
		super(model, session, 'important-infos')
	end	
	def google_search(model, session)
		glink = CGI.escape(model.name_base.to_s)
		link = HtmlGrid::Link.new(:google_search, @model, @session, self)	
		link.href =  "http://www.google.com/search?q=#{glink}"
		link.css_class= 'google_search square'
		link.set_attribute('title', "#{@lookandfeel.lookup(:google_alt)}#{model.name_base}")
		link
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
	def most_precise_dose(model, session)
		if(model.respond_to?(:most_precise_dose))
			dose = model.most_precise_dose
			(dose && (dose.qty > 0)) ? dose : nil
		end
	end
	def name_base(model, session)
		link = HtmlGrid::PopupLink.new(:compare, model, session, self)
		link.href = @lookandfeel.event_url(:compare, {'pointer'=>model.pointer})
		link.value = breakline(model.name_base, 25)
		link.set_attribute('class', 'result-big' << resolve_suffix(model))
		indication = model.registration.indication
		title = [
			@lookandfeel.lookup(:ean_code, model.barcode),
			(indication.send(@session.language) unless(indication.nil?)),
		].compact.join(', ')
		link.set_attribute('title', title)
		link.width = 950
		link
	end
	def notify(model, session)
		link = HtmlGrid::Link.new(:notify, model, session, self)
		args = {
			:pointer => model.pointer,
		}
		link.href = @lookandfeel.event_url(:notify, args)
		img = HtmlGrid::Image.new(:notify, model, session, self)
		img.set_attribute('src', @lookandfeel.resource_global(:notify))
		link.value = img
		link.set_attribute('title', @lookandfeel.lookup(:notify_alt))
		link
	end
	def substances(model, session)
		link = HtmlGrid::Link.new(:show, model, session, self)
		link.href = @lookandfeel.event_url(:show, {:pointer => model.pointer})
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
