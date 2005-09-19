#!/usr/bin/env ruby
# View::Drugs::Package -- oddb -- 15.02.2005 -- hwyss@ywesee.com

require 'view/privatetemplate'
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
		[0,0]		=>	:ikskey,
		[2,0]		=>	:registration_holder,
		[0,1]		=>	:name,
		[2,1]		=>	:most_precise_dose,
		[0,2]		=>	:atc_class,
		[1,2,1]	=>	:atc_ddd_link,
		[2,2]		=>	:descr,
		[0,3]		=>	:galenic_form,
		[2,3]		=>	:size,
		[0,4]		=>	:ikscat,
		[2,4]		=>	:indication,
		[0,5]		=>	:fachinfo_label,
		[1,5]		=>	:fachinfo,
		[2,5]		=>	:patinfo_label,
		[3,5]		=>	:patinfo,
		[0,6]		=>	:sl_entry,
		[0,7]		=>	:price_exfactory,
		[2,7]		=>	:price_public,
		[0,8]		=>	:feedback_label,
		[1,8]		=>	:feedback,
	}
	CSS_MAP = {
		[0,0,4,9]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	COLSPAN_MAP = { }
	SYMBOL_MAP = {
		:sl_entry				=>	HtmlGrid::BooleanValue,
		:limitation			=>	HtmlGrid::BooleanValue,
		:patinfo_label	=> HtmlGrid::LabelText,
		:fachinfo_label	=> HtmlGrid::LabelText,
		:feedback_label	=> HtmlGrid::LabelText,
	}
	def init
		if(@model.sl_entry)
			components.store([2,6], :limitation)
			if(@model.limitation_text)
				colspan_map.store([1,7], 3)
				components.update({
					[0,7]		=>	:limitation_text,
					[0,8]		=>	:price_exfactory,
					[2,8]		=>	:price_public,
				})
				css_map.store([0,8,4], 'list')
			end
		end
		super
	end
	def atc_class(model, session)
		val = HtmlGrid::Value.new(:atc_class, model, @session, self)
		if(atc = model.atc_class)
			val.value = atc_description(atc, @session)
		end
		val
	end
	def atc_ddd_link(model, session)
		if(atc = model.atc_class)
			super(atc, session)
		end
	end
	def registration_holder(model, session)
		HtmlGrid::Value.new(:company_name, model, @session, self)
	end
	def limitation_text(model, session)
		text = HtmlGrid::Value.new(:limitation_text, model, @session, self)
		if(lim = model.limitation_text)
			text.value = lim.send(@session.language)
		end
		text
	end
	def most_precise_dose(model, session)
		HtmlGrid::Value.new(:most_precise_dose, model, session, self)
	end
end
class PackageComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Drugs::PackageInnerComposite,
		[0,3]	=>	:sequence_agents,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	def package_name(model, session)
		[model.name, model.size].compact.join('&nbsp;-&nbsp;')
	end
	def sequence_agents(model, session)
		if(agents = model.sequence.active_agents)
			View::Admin::SequenceAgents.new(agents, session, self)
		end
	end
end
class Package < View::PrivateTemplate
	CONTENT = View::Drugs::PackageComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
