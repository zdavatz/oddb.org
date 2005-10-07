#!/usr/bin/env ruby
# View::Admin::Sequence -- oddb -- 11.03.2003 -- hwyss@ywesee.com 

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
		module Admin
module SequenceAgentList
	COMPONENTS = {
		[0,0]	=>	:substance,
		[1,0]	=>	:dose,
		[3,0]	=>	:chemical_substance,
		[4,0]	=>	:chemical_dose,
		[6,0]	=>	:equivalent_substance,
		[7,0]	=>	:equivalent_dose,
	}
	CSS_HEAD_MAP = {
		[1,0]	=>	'subheading-r',
		[4,0]	=>	'subheading-r',
	}
	CSS_MAP = {
		[0,0]	=>	'list',
		[1,0]	=>	'list-r',
		[2,0,2]	=>	'list',
		[4,0]	=>	'list-r',
		[5,0,2]	=>	'list',
		[7,0]	=>	'list-r',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	EVENT = :new_active_agent	
	SORT_HEADER = false
	def substance(model, session)
		if(sub = model.substance)
			sub.name
		end
	end
end
class SequenceAgents < HtmlGrid::List
	include View::Admin::SequenceAgentList
end
class RootSequenceAgents < View::FormList
	include SequenceAgentList
	def substance(model, session)
		link = View::PointerLink.new(:substance, model, session, self)
		link.value = super
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
	include View::Admin::SequencePackageList
end
class RootSequencePackages < View::FormList
	include View::Admin::SequencePackageList
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
	def atc_request(model, session)
		if(time = model.atc_request_time)
			days = ((((Time.now - @model.atc_request_time) / 60) / 60) / 24)
				output = "#{@lookandfeel.lookup(:atc_request_time)}"
			if(days > 1)
				output + "#{days.round} #{@lookandfeel.lookup(:atc_request_days)}"
			else
				days = (days * 24)  
				output + "#{days.round} #{@lookandfeel.lookup(:atc_request_hours)}"
			end
		else
			button = HtmlGrid::Button.new(:atc_request, @model, @session, self)
			button.value = @lookandfeel.lookup(:atc_request)
			url = @lookandfeel.event_url(:atc_request)
			button.set_attribute('onclick', "location.href='#{url}'")
			button
		end
	end
end
class SequenceInnerComposite < HtmlGrid::Composite
	include View::Admin::SequenceDisplay
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
	include View::Admin::SequenceDisplay
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
	}
	COMPONENT_CSS_MAP = {
		[0,0,4,4]	=>	'standard',
	}
	CSS_MAP = {
		[0,0,4,5]	=>	'list',
	}
	DISABLE_ADDITIONAL_CSS = true
	LABELS = true
	TAG_METHOD = :multipart_form
	SYMBOL_MAP = {
		:iksnr							=>	HtmlGrid::Value,
		:patinfo_label			=> HtmlGrid::LabelText,
		:atc_request_label	=> HtmlGrid::LabelText,
		:no_company					=> HtmlGrid::LabelText,
		:regulatory_email		=> HtmlGrid::InputText,
	}
	def init
		if(@model.is_a?(Persistence::CreateItem))
			components.store([1,4], :submit)
		else
			components.update({
				[0,4]		=>	:patinfo_upload,
				[2,4]   =>  :patinfo_label,
				[3,4,1] =>  :patinfo,
				[3,4,2] =>  :assign_patinfo,
				[3,4,3] =>  :delete_patinfo,
				[1,5]		=>	:submit,
				[1,5,0] =>  :delete_item,
			})
			css_map.update({
				[3,4]		=>	'result-infos',
				[0,5,4] =>	'list',
			})
			if(@model.atc_class.nil? && !atc_descr_error?)
			  if(@model.company.nil?)
					components.store([5,3], :atc_request_label)
					components.store([3,3], :no_company)
				else
					if(@model.company.regulatory_email.to_s.empty?)
						components.store([2,3], :regulatory_email)
					else
						components.store([2,3], :atc_request_label)
						components.store([3,3], :atc_request)
					end
				end
			end
		end
		super
		error_message()
	end
	def assign_patinfo(model, session)
		unless(@model.is_a? Persistence::CreateItem)
			link = HtmlGrid::Link.new(:assign_patinfo, model, session, self)
			link.href = @lookandfeel.event_url(:assign_patinfo)
			link.set_attribute('class', 'small')
			link
		end
	end
	def atc_descr(model, session)
		if(atc_descr_error?)
			HtmlGrid::InputText.new(:atc_descr, model, session, self)
		else
			super
		end
	end
	def atc_descr_error?
		((err = @session.error(:atc_class)) \
			&& err.message == "e_unknown_atc_class") \
			|| ((atc = @model.atc_class) \
			&& atc.description.empty?)
	end
	def delete_item(model, session)
		delete_item_warn(model, :w_delete_sequence)
	end
	def delete_patinfo(model, session)
		if(model.has_patinfo?)
			button = HtmlGrid::Button.new(:delete_patinfo, 
				model, session, self)
			script = "this.form.patinfo.value = 'delete'; this.form.submit();"
			button.set_attribute('onclick', script)
			button
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
	def profile_link(model, session)
		if(comp = model.company)
			link = HtmlGrid::Link.new(:company_link, model, session, self)  
			args = { :pointer	=>	comp.pointer }
			link.href = @lookandfeel._event_url(:resolve, args)
			link.set_attribute('class', 'small')
			link.label = false
			link  
		end
	end
	def patinfo_label(model, session)
		HtmlGrid::LabelText.new(:patinfo, model, session , self)
	end
	def patinfo_upload(model, session)
		HtmlGrid::InputFile.new(:patinfo_upload, model, session, self)
	end
	def hidden_fields(context)
		super << context.hidden('patinfo', 'keep')
	end
end
class SequenceComposite < HtmlGrid::Composite
	AGENTS = View::Admin::SequenceAgents
	COMPONENTS = {
		[0,0]	=>	:sequence_name,
		[0,1]	=>	View::Admin::SequenceInnerComposite,
		[0,2]	=>	:sequence_agents,
		[0,3]	=>	:sequence_packages,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th'
	}
	PACKAGES = View::Admin::SequencePackages
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
class RootSequenceComposite < View::Admin::SequenceComposite
	AGENTS = View::Admin::RootSequenceAgents
	COMPONENTS = {
		[0,0]	=>	:sequence_name,
		[0,1]	=>	View::Admin::SequenceForm,
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
	PACKAGES = View::Admin::RootSequencePackages
end
class Sequence < View::PrivateTemplate
	CONTENT = View::Admin::SequenceComposite
	SNAPBACK_EVENT = :result
end
class RootSequence < View::Admin::Sequence
	CONTENT = View::Admin::RootSequenceComposite
end
		end
	end
end
