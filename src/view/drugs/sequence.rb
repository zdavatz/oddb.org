#!/usr/bin/env ruby
# View::Drugs::Sequence -- oddb -- 11.03.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'
require 'view/form'
require 'view/dataformat'
require 'view/pointervalue'
require 'htmlgrid/errormessage'
require 'htmlgrid/text'
require 'htmlgrid/labeltext'
require 'util/pointerarray'

module ODDB
	module View
		module Drugs
module SequenceAgentList
	COMPONENTS = {
		[0,0]	=>	:substance,
		[1,0]	=>	:dose,
	}
	CSS_HEAD_MAP = {
		[1,0]	=>	'subheading-r',
	}
	CSS_MAP = {
		[0,0]	=>	'list',
		[1,0]	=>	'list-r',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	EVENT = :new_active_agent	
	SORT_HEADER = false
end
class SequenceAgents < HtmlGrid::List
	include View::Drugs::SequenceAgentList
end
class RootSequenceAgents < View::FormList
	include SequenceAgentList
	def substance(model, session)
		link = View::PointerLink.new(:substance, model, session, self)
		link.value = model.substance.name if(model.substance)
		link
	end
end
module SequencePackageList 
		include DataFormat
	COMPONENTS = {
		[0,0]	=>	:ikscd,
		[1,0]	=>	:most_precise_dose,
		[2,0]	=>	:size,
		[3,0]	=>	:price_exfactory,
		[4,0]	=>	:price_public,
		[5,0]	=>	:ikscat,
		[6,0]	=>	:sl_entry,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'list',
		[1,0]	=>	'list-r',
		[2,0]	=>	'list-r',
		[3,0]	=>	'list-r',
		[4,0]	=>	'list-r',
		[5,0]	=>	'list-r',
		[6,0]	=>	'list-r',
	}
	CSS_HEAD_MAP = {
		[0,0]	=>	'subheading',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading-r'
	EVENT = :new_package
	SORT_DEFAULT = :ikscd
	SORT_HEADER = false
	SYMBOL_MAP = {
		:ikscd =>	View::PointerLink,
	}
	def sl_entry(model, session)
		@lookandfeel.lookup(:sl) unless model.sl_entry.nil?
	end
end
class SequencePackages < HtmlGrid::List
	include View::Drugs::SequencePackageList
end
class RootSequencePackages < View::FormList
	include View::Drugs::SequencePackageList
end
module SequenceDisplay
	def atc_class(model, session)
		self::class::DEFAULT_CLASS.new(:code, model.atc_class, session, self)
	end	
	def atc_descr(model, session)
		if(atc = model.atc_class)
			txt = HtmlGrid::Text.new(:atc_descr, model, session, self)
			txt.label = true
			txt.value = atc.description(@lookandfeel.language)
			txt
		end
	end
end
class SequenceInnerComposite < HtmlGrid::Composite
	include View::Drugs::SequenceDisplay
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:seqnr,
		[0,1]		=>	:name_base,
		[2,1]		=>	:name_descr,
		[0,2]		=>	:dose,
		[2,2]		=>	:galenic_form,
		[0,3]		=>	:atc_class,
		[2,3]		=>	:atc_descr,
	}
	CSS_MAP = {
		[0,0,4,4]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
end
class SequenceForm < Form
	include HtmlGrid::ErrorMessage
	include View::Drugs::SequenceDisplay
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:seqnr,
		[0,1]		=>	:name_base,
		[2,1]		=>	:name_descr,
		[0,2]		=>	:dose,
		[2,2]		=>	:galenic_form,
		[0,3]		=>	:atc_class,
		[2,3]		=>	:atc_descr,
		[0,4]		=>	:patinfo_upload,
		[1,5]		=>	:submit,
		[1,5,0] =>  :delete_item,
		[2,5]   =>  :patinfo_desc,
		[3,5,1] =>  :patinfo,
		[3,5,2] =>  :assign_patinfo,
	}
	COMPONENT_CSS_MAP = {
		[0,0,4,4]	=>	'standard',
	}
	CSS_MAP = {
		[0,0,5,5]	=>	'list',
		[2,5]     =>	'list',
		[3,5]			=>	'result-infos',
	}
	DISABLE_ADDITIONAL_CSS = true
	LABELS = true
	TAG_METHOD = :multipart_form
	SYMBOL_MAP = {
		:iksnr	=>	HtmlGrid::Value,
		:patinfo_desc => HtmlGrid::LabelText,
	}
	def init
		super
		error_message()
	end
	def patinfo_upload(model, session)
		HtmlGrid::InputFile.new(:patinfo_upload, model, session, self)
	end
	def patinfo_label(model, session)
		HtmlGrid::LabelText.new(:patinfo, model, session , self)
	end
	def assign_patinfo(model, session)
		unless(@model.is_a? Persistence::CreateItem)
			link = HtmlGrid::Link.new(:assign_patinfo, model, session, self)
			link.href = @lookandfeel.event_url(:assign_patinfo)
			link.set_attribute('class', 'small')
			link
		end
	end
	def seqnr(model, session)
		klass = if(model.seqnr.nil?)
			HtmlGrid::InputText
		else
			HtmlGrid::Value
		end
		klass.new(:seqnr, model, session, self)
	end
	def patinfo(model, session)
		if(link = super)
			pos = components.index(:patinfo)
			link.set_attribute('class', 'result-infos')
			link
		end
	end
	def atc_descr(model, session)
		if(((err = session.error(:atc_class)) \
			&& err.message == "e_unknown_atc_class") \
			|| ((atc = model.atc_class) \
			&& atc.description.empty?))

			HtmlGrid::InputText.new(:atc_descr, model, session, self)
		else
			super
		end
	end
end
class SequenceComposite < HtmlGrid::Composite
	AGENTS = View::Drugs::SequenceAgents
	COMPONENTS = {
		[0,0]	=>	:sequence_name,
		[0,1]	=>	View::Drugs::SequenceInnerComposite,
		[0,2]	=>	:sequence_agents,
		[0,3]	=>	:sequence_packages,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th'
	}
	PACKAGES = View::Drugs::SequencePackages
	def sequence_name(model, session)
		[ 
			(model.company.name if model.company),
			model.name,
		].compact.join('&nbsp;-&nbsp;')
		#HtmlGrid::Value.new('name', model, session, self)
	end
	def sequence_agents(model, session)
		if(agents = model.active_agents)
			values = ODDB::PointerArray.new(agents, model.pointer)
			self::class::AGENTS.new(values, session, self)
		end
	end
	def sequence_packages(model, session)
		if(packages = model.packages)
			values = ODDB::PointerArray.new(packages.values, model.pointer)
			self::class::PACKAGES.new(values, session, self)
		end
	end
end
class RootSequenceComposite < View::Drugs::SequenceComposite
	AGENTS = View::Drugs::RootSequenceAgents
	COMPONENTS = {
		[0,0]	=>	:sequence_name,
		[0,1]	=>	View::Drugs::SequenceForm,
		[0,2]	=>	:sequence_agents,
		[0,3]	=>	:sequence_packages,
		[0,4]	=>	"th_source",
		[0,5]	=>	:source,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,4]	=>	'subheading',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	PACKAGES = View::Drugs::RootSequencePackages
end
class Sequence < View::PrivateTemplate
	CONTENT = View::Drugs::SequenceComposite
	SNAPBACK_EVENT = :result
end
class RootSequence < View::Drugs::Sequence
	CONTENT = View::Drugs::RootSequenceComposite
end
		end
	end
end
