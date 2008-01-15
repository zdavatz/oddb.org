#!/usr/bin/env ruby
# View::Drugs::Package -- oddb -- 15.02.2005 -- hwyss@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/additional_information'
require 'view/admin/sequence'
require 'htmlgrid/booleanvalue'

module ODDB
	module View
		module Drugs
class PackageInnerComposite < HtmlGrid::Composite
	include DataFormat
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0,0]	=>	:ikskey,
		[1,0,0]	=>	"&nbsp;",
		[1,0,1]	=>	:comarketing,
		[2,0]		=>	:registration_holder,
		[0,1]		=>	:name,
		[2,1]		=>	:registration_date,
		[0,2]		=>	:most_precise_dose,
		[2,2]		=>	:revision_date,
		[0,3,0]	=>	:atc_class,
		[1,3,1]	=>	:atc_ddd_link,
		[2,3]		=>	:expiration_date,
		[0,4]		=>	:galenic_form,
		[2,4]		=>	:size,
		[2,5]		=>	:descr,
		[0,6]		=>	:ikscat,
		[2,6]		=>	:indication,
		[0,7]		=>	:sl_entry,
		[0,8]		=>	:price_exfactory,
		[2,8]		=>	:price_public,
		[0,9]	  =>	:deductible,
	}
	CSS_MAP = {
		[0,0,4]	=>	'list',
		[0,1,4]	=>	'list',
		[0,2,4]	=>	'list',
		[0,3,4]	=>	'list',
		[0,4,4]	=>	'list',
		[0,5,4]	=>	'list',
		[0,6,4]	=>	'list',
		[0,7,4]	=>	'list',
		[0,8,4]	=>	'list',
		[0,9,4]	=>	'list',
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
		:patinfo_label			=>	HtmlGrid::LabelText,
		:fachinfo_label			=>	HtmlGrid::LabelText,
		:feedback_label			=>	HtmlGrid::LabelText,
		:narcotic_label			=>	HtmlGrid::LabelText,
		:registration_date	=>	HtmlGrid::DateValue,
		:revision_date			=>	HtmlGrid::DateValue,
		:expiration_date		=>	HtmlGrid::DateValue,
	}
	def init
    if(@model.narcotic?)
      components.update([2,10] => :narcotic_label, [3,10] => :narcotic)
      css_map.store([0,10,4], 'list')
    end
    if(@lookandfeel.enabled?(:feedback))
      components.update([0,10] => :feedback_label, [1,10] => :feedback)
      css_map.store([0,10,4], 'list')
    end
    if(@model.ddd_price)
      components.store([2,9], :ddd_price)
    end
		if(@model.sl_entry)
			components.store([2,7], :limitation)
			if(@model.limitation_text)
        hash_insert_row(components, [0,8], :limitation_text)
        hash_insert_row(css_map, [0,8,4], 'list')
      end
		end
    if(@lookandfeel.enabled?(:fachinfos))
      hash_insert_row(components, [0,7], :fachinfo_label)
      hash_insert_row(css_map, [0,7,4], 'list')
      components.update({
        [1,7]		=>	:fachinfo,
        [2,7]		=>	:patinfo_label,
        [3,7]		=>	:patinfo,
      })
    elsif(@lookandfeel.enabled?(:patinfos))
      hash_insert_row(components, [2,7], :patinfo_label)
      hash_insert_row(css_map, [0,7,4], 'list')
      components.store([3,7], :patinfo)
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
      :search_query => model.name_base, 
      :search_type => :st_oddb,
    }
    link.href = @lookandfeel._event_url(:search, args, 'best_result')
    link
  end
	def registration_holder(model, session=@session)
		HtmlGrid::Value.new(:company_name, model, @session, self)
	end
end
class PackageComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Drugs::PackageInnerComposite,
		[0,3]	=>	:sequence_agents,
		[0,4]	=>	'th_source',
		[0,5]	=>	:source,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,4]	=>	'subheading',
    [0,5] =>  'list',
	}
  DEFAULT_CLASS = HtmlGrid::Value
	def package_name(model, session)
		[model.name, model.size].compact.join('&nbsp;-&nbsp;')
	end
	def sequence_agents(model, session)
		if(agents = model.sequence.active_agents)
			View::Admin::SequenceAgents.new(agents, session, self)
		end
	end
end
class Package < PrivateTemplate
	CONTENT = View::Drugs::PackageComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
