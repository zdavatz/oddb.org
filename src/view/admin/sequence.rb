#!/usr/bin/env ruby
# View::Admin::Sequence -- oddb -- 11.03.2003 -- hwyss@ywesee.com 

require 'view/drugs/privatetemplate'
require 'view/form'
require 'view/dataformat'
require 'view/pointervalue'
require 'htmlgrid/booleanvalue'
require 'htmlgrid/errormessage'
require 'htmlgrid/text'
require 'htmlgrid/labeltext'
require 'util/pointerarray'

module ODDB
	module View
		module Admin
module SequenceAgentList
	COMPONENTS = {
		[0,0]	=>	:narcotic,
		[1,0]	=>	:substance,
		[2,0]	=>	:dose,
		[4,0]	=>	:chemical_substance,
		[5,0]	=>	:chemical_dose,
		[7,0]	=>	:equivalent_substance,
		[8,0]	=>	:equivalent_dose,
		[9,0]	=>	:spagyric_dose,
	}
	CSS_HEAD_MAP = {
		[2,0]	=>	'subheading right',
		[5,0]	=>	'subheading right',
	}
	CSS_MAP = {
		[1,0]		=>	'list',
		[2,0]		=>	'list right',
		[3,0,2]	=>	'list',
		[5,0]		=>	'list right',
		[6,0,2]	=>	'list',
		[8,0,2]	=>	'list right',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	EVENT = :new_active_agent	
	SORT_HEADER = false
	SORT_DEFAULT = :to_a
	def substance(model, session=@session)
		link = HtmlGrid::Link.new(:substance, model, @session, self)
		link.value = _substance(model)
		args = {:pointer => model.pointer}
		link.href = @lookandfeel.event_url(:suggest_choose, args)
		link
	end
	def _substance(model)
		if(sub = model.substance)
			sub.name
		end
	end
	def narcotic(model, session=@session)
		if((sub = model.substance) && (narc = sub.narcotic))
			link = HtmlGrid::Link.new(:narc_short,
																narc, @session, self)
			link.href = @lookandfeel._event_url(:resolve,
																					{'pointer' => narc.pointer})
			link.css_class = 'square infos'
			link.set_attribute('title', @lookandfeel.lookup(:nacotic))
			link
		end
	end
end
class SequenceAgents < HtmlGrid::List
	include View::Admin::SequenceAgentList
end
class RootSequenceAgents < View::FormList
	include SequenceAgentList
	EMPTY_LIST_KEY = :empty_agent_list
	def substance(model, session)
		link = View::PointerLink.new(:substance, model, session, self)
		link.value = _substance(model)
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
		[7,0]	=>	:out_of_trade,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]		=>	'list',
		[1,0,7]	=>	'list right',
	}
	CSS_HEAD_MAP = {
		[0,0]	=>	'subheading',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading right'
	EVENT = :new_package
	SORT_DEFAULT = :ikscd
	SORT_HEADER = false
	SYMBOL_MAP = {
		:ikscd				=>	View::PointerLink,
		:out_of_trade	=>	HtmlGrid::BooleanValue,
	}
	def ikscd(model, session=@session)
		if(@session.user.allowed?('edit', 'org.oddb.drugs'))
			PointerLink.new(:ikscd, model, @session, self)
		else
			link = HtmlGrid::Link.new(:ikscd, model, @session, self)
			link.value = model.ikscd
			args = {:pointer => model.pointer}
			link.href = @lookandfeel.event_url(:suggest_choose, args)
			link
		end
	end
	def sl_entry(model, session=@session)
		@lookandfeel.lookup(:sl) unless model.sl_entry.nil?
	end
end
class SequencePackages < HtmlGrid::List
	include View::Admin::SequencePackageList
end
class RootSequencePackages < View::FormList
	include View::Admin::SequencePackageList
	EMPTY_LIST_KEY = :empty_package_list
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
		reorganize_components
		super
		error_message()
	end
	def reorganize_components
		if(@model.is_a?(ODDB::Sequence))
			components.update({
				[0,4]		=>	:patinfo_upload,
				[2,4]   =>  :patinfo_label,
				[3,4,1] =>  :patinfo,
				[3,4,2] =>  :assign_patinfo,
				[3,4,3] =>  :delete_patinfo,
				[1,5,0]	=>	:submit,
				[1,5,1] =>  :delete_item,
			})
			css_map.update({
				[3,4]		=>	'list',
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
		else
			components.store([1,4], :submit)
		end
	end
	def assign_patinfo(model, session=@session)
		link = HtmlGrid::Link.new(:assign_patinfo, model, session, self)
		link.href = @lookandfeel.event_url(:assign_patinfo)
		if(@model.has_patinfo?)
			link.value = @lookandfeel.lookup(:assign_this_patinfo)
		else
			link.value = @lookandfeel.lookup(:assign_other_patinfo)
		end
		link.set_attribute('class', 'small')
		link
	end
	def atc_descr(model, session=@session)
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
	def delete_item(model, session=@session)
		delete_item_warn(model, :w_delete_sequence)
	end
	def delete_patinfo(model, session=@session)
		if(model.has_patinfo?)
			button = HtmlGrid::Button.new(:delete_patinfo, 
																		model, session, self)
			script = "this.form.patinfo.value = 'delete'; this.form.submit();"
			button.set_attribute('onclick', script)
			button
		end
	end
	def seqnr(model, session=@session)
		klass = if(model.seqnr.nil?)
							HtmlGrid::InputText
						else
							HtmlGrid::Value
						end
		klass.new(:seqnr, model, session, self)
	end
	def patinfo(model, session=@session)
		if(link = super)
			pos = components.index(:patinfo)
			link.set_attribute('class', 'square infos')
			link
		end
	end
	def profile_link(model, session=@session)
		if(comp = model.company)
			link = HtmlGrid::Link.new(:company_link, model, session, self)  
			args = { :pointer	=>	comp.pointer }
			link.href = @lookandfeel._event_url(:resolve, args)
			link.set_attribute('class', 'small')
			link.label = false
			link  
		end
	end
	def patinfo_label(model, session=@session)
		HtmlGrid::LabelText.new(:patinfo, model, session , self)
	end
	def patinfo_upload(model, session=@session)
		if(model.company.invoiceable?)
			HtmlGrid::InputFile.new(:patinfo_upload, model, @session, self)
		else
			PointerLink.new(:e_company_not_invoiceable, model.company, @session, self)
		end
	end
	def hidden_fields(context)
		super << context.hidden('patinfo', 'keep')
	end
end
class ResellerSequenceForm < SequenceForm
	include HtmlGrid::ErrorMessage
	include View::Admin::SequenceDisplay
	include View::AdditionalInformation
	DEFAULT_CLASS = HtmlGrid::Value
end
class SequenceComposite < HtmlGrid::Composite
	AGENTS = View::Admin::RootSequenceAgents
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
class ResellerSequenceComposite < View::Admin::SequenceComposite
	COMPONENTS = {
		[0,0]	=>	:sequence_name,
		[0,1]	=>	View::Admin::ResellerSequenceForm,
		[0,2]	=>	:sequence_agents,
		[0,3]	=>	:sequence_packages,
		[0,4]	=>	"th_source",
		[0,5]	=>	:source,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,4]	=>	'subheading',
		[0,5]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	PACKAGES = View::Admin::RootSequencePackages
end
class Sequence < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::SequenceComposite
	SNAPBACK_EVENT = :result
end
class RootSequence < View::Admin::Sequence
	CONTENT = View::Admin::RootSequenceComposite
end
class ResellerSequence < View::Admin::Sequence
	CONTENT = View::Admin::ResellerSequenceComposite
end
		end
	end
end
