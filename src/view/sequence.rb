#!/usr/bin/env ruby
# SequenceView -- oddb -- 11.03.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'
require 'view/form'
require 'view/dataformat'
require 'view/pointervalue'
require 'htmlgrid/errormessage'
require 'htmlgrid/text'
require 'util/pointerarray'

module ODDB
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
		include SequenceAgentList
	end
	class RootSequenceAgents < FormList
		include SequenceAgentList
		def substance(model, session)
			link = PointerLink.new(:substance, model, session, self)
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
			:ikscd =>	PointerLink,
		}
		def sl_entry(model, session)
			@lookandfeel.lookup(:sl) unless model.sl_entry.nil?
		end
	end
	class SequencePackages < HtmlGrid::List
		include SequencePackageList
	end
	class RootSequencePackages < FormList
		include SequencePackageList
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
		include SequenceDisplay
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
		include SequenceDisplay
		include AdditionalInformation
		COMPONENTS = {
			[0,0]		=>	:iksnr,
			[2,0]		=>	:seqnr,
			[0,1]		=>	:name_base,
			[2,1]		=>	:name_descr,
			[0,2]		=>	:dose,
			[2,2]		=>	:galenic_form,
			[0,3]		=>	:atc_class,
			[2,3]		=>	:atc_descr,
			[1,4]		=>	:submit,
			[1,4,0] =>  :delete_item,
			[2,4]   =>  :patinfo_desc,
			[3,4,1] =>  :patinfo,
			[3,4,2] =>  :assign_patinfo,
		}
		COMPONENT_CSS_MAP = {
			[0,0,4,4]	=>	'standard',
		}
		CSS_MAP = {
			[0,0,4,4]	=>	'list',
			[2,4]     =>	'list',
			[3,4]			=>	'result-infos',
		}
		DISABLE_ADDITIONAL_CSS = true
		LABELS = true
		SYMBOL_MAP = {
			:iksnr	=>	HtmlGrid::Value,
			:patinfo_desc => HtmlGrid::LabelText,
		}
		def init
			super
			error_message()
		end
		def assign_patinfo(model, session)
			unless(@model.is_a? Persistence::CreateItem)
				link = HtmlGrid::Link.new(:assign_patinfo, model, session, self)
				link.href = @lookandfeel.event_url(:assign_patinfo, hash)
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
		AGENTS = SequenceAgents
		COMPONENTS = {
			[0,0]	=>	:sequence_name,
			[0,1]	=>	SequenceInnerComposite,
			[0,2]	=>	:sequence_agents,
			[0,3]	=>	:sequence_packages,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th'
		}
		PACKAGES = SequencePackages
		def sequence_name(model, session)
			[ 
				(model.company.name if model.company),
				model.name,
			].compact.join('&nbsp;-&nbsp;')
			#HtmlGrid::Value.new('name', model, session, self)
		end
		def sequence_agents(model, session)
			if(agents = model.active_agents)
				values = PointerArray.new(agents, model.pointer)
				self::class::AGENTS.new(values, session, self)
			end
		end
		def sequence_packages(model, session)
			if(packages = model.packages)
				values = PointerArray.new(packages.values, model.pointer)
				self::class::PACKAGES.new(values, session, self)
			end
		end
	end
	class RootSequenceComposite < SequenceComposite
		AGENTS = RootSequenceAgents
		COMPONENTS = {
			[0,0]	=>	:sequence_name,
			[0,1]	=>	SequenceForm,
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
		PACKAGES = RootSequencePackages
	end
	class SequenceView < PrivateTemplate
		CONTENT = SequenceComposite
		SNAPBACK_EVENT = :result
	end
	class RootSequenceView < SequenceView
		CONTENT = RootSequenceComposite
	end
end
