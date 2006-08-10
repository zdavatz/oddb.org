#!/usr/bin/env ruby
# View::Admin::Registration -- oddb -- 07.03.2003 -- hwyss@ywesee.com 

require 'view/drugs/privatetemplate'
require 'htmlgrid/errormessage'
require 'htmlgrid/datevalue'
require 'htmlgrid/inputdate'
require 'htmlgrid/select'
require 'htmlgrid/inputfile'
require 'htmlgrid/inputcheckbox'
require 'view/pointervalue'
require 'view/additional_information'
require 'view/inputdescription'
require 'view/form'

module ODDB
	module View
		module Admin
module RegistrationSequenceList 
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0]	=>	:seqnr,
		[1,0]	=>	:name_base,
		[2,0]	=>	:name_descr,
		[3,0]	=>	:dose, 
		[4,0]	=>	:galenic_form,
		[5,0]	=>	:atc_class,
		[6,0] =>	:patinfo,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,7]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	EVENT = :new_sequence
	SORT_HEADER = false
	SORT_DEFAULT = :seqnr
	SYMBOL_MAP = {
		:seqnr	=>	View::PointerLink,
	}
	def atc_class(model, session=@session)
		if atc = model.atc_class
			atc.code
		end
	end
	def seqnr(model, session=@session)
		if(@session.user.allowed?('edit', model))
			PointerLink.new(:seqnr, model, @session, self)
		else
			link = HtmlGrid::Link.new(:seqnr, model, @session, self)
			args = {:pointer => model.pointer}
			link.href = @lookandfeel.event_url(:suggest_choose, args)
			link.value = model.seqnr
			link
		end
	end
end
class RegistrationSequences < HtmlGrid::List
	include View::Admin::RegistrationSequenceList
end
class RootRegistrationSequences < View::FormList
	include View::Admin::RegistrationSequenceList
	EMPTY_LIST_KEY = :empty_sequence_list
	def compose_empty_list(offset)
		@grid.add(@lookandfeel.lookup(self::class::EMPTY_LIST_KEY), 
			*offset)
		@grid.add_attribute('class', 'list', *offset)
		#@grid[*offset].add_style('list')
		@grid.set_colspan(*offset)
		resolve_offset(offset, self::class::OFFSET_STEP)
	end
end
class FachinfoLanguageSelect < HtmlGrid::AbstractSelect
	attr_accessor :value
	def selection(context)
		values = ["de","fr"]
		values.collect { |value|
			attributes = { "value"	=>	value.to_s }
			attributes.store("selected", true) if(@value == value)
			context.option(attributes) { 
				@lookandfeel.lookup(value)
			}
		}
	end
end
class RegistrationInnerComposite < HtmlGrid::Composite
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:registration_date,
		[0,1]		=>	:company_name,
		[2,1]		=>	:revision_date,
		[0,2]		=>	:generic_type,
		[2,2]		=>	:expiration_date,
		[0,3]		=>	:indication,
		[2,3]		=>	:market_date,
		[2,4]		=>	:inactive_date,
		[2,5]		=>  :fachinfo_label,
	}
	CSS_MAP = {
		[0,0,4,6]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	SYMBOL_MAP = {
		:expiration_date		=>	HtmlGrid::DateValue,
		:fachinfo_label			=>	HtmlGrid::LabelText,
		:inactive_date			=>	HtmlGrid::DateValue,
		:market_date		  	=>	HtmlGrid::DateValue,
		:registration_date	=>	HtmlGrid::DateValue,
		:revision_date			=>	HtmlGrid::DateValue,
	}
	def generic_type(model, session)
		label(HtmlGrid::Text.new(model.generic_type, model, session, self))
	end
end
module FachinfoPdfMethods
	TAG_METHOD = :multipart_form
	def assign_fachinfo(model, session=@session)
		link = HtmlGrid::Link.new(:assign_fachinfo, model, session, self)
		link.href = @lookandfeel.event_url(:assign_fachinfo)
		if(@model.fachinfo)
			link.value = @lookandfeel.lookup(:assign_this_fachinfo)
		end
		link.set_attribute('class', 'small')
		link
	end
	def fachinfo_upload(model, session=@session)
		input = HtmlGrid::InputFile.new(:fachinfo_upload, model, session, self)
		input.label = false
		input
	end
	def language_select(model, session=@session)
		sel = View::Admin::FachinfoLanguageSelect.new(:language_select, model, 
			session, self)
		sel.label = false
		sel
	end
end
class RegistrationForm < View::Form
	include HtmlGrid::ErrorMessage
	include View::AdditionalInformation
	include FachinfoPdfMethods
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:registration_date,
		[0,1]		=>	:company_name,
		[2,1]		=>	:revision_date,
		[0,2]		=>	:generic_type,
		[2,2]		=>	:expiration_date,
		[4,2]		=>	:renewal_flag,
		[0,3,0]	=>	:complementary_select,
		[0,3,1]	=>	:complementary_type,
		[2,3]		=>	:market_date,
		[0,4]		=>	:index_therapeuticus,
		[2,4]		=>	:inactive_date,
		[0,5]		=>	:indication,
		[2,5]		=>	:patented_until,
		[0,6]		=>	:export_flag,
		[2,6]		=>	:vaccine,
		[0,7]		=>	:parallel_import,
	}
	COMPONENT_CSS_MAP = {
		[1,0,1,6]	=>	'standard',
		[3,0,1,6]	=>	'standard',
	}
	CSS_MAP = {
		[0,0,6,8]	=>	'list',
		[0,8]			=>	'list',
	}
  COLSPAN_MAP = { }
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	SYMBOL_MAP = {
		:expiration_date		=>	HtmlGrid::InputDate,
		:export_flag				=>	HtmlGrid::InputCheckbox,
		:vaccine						=>	HtmlGrid::InputCheckbox,
		:fachinfo_label			=>	HtmlGrid::LabelText,
		:generic_type				=>	HtmlGrid::Select,
		:inactive_date			=>	HtmlGrid::InputDate,
		:index_therapeuticus=>	HtmlGrid::InputText,
		:market_date				=>	HtmlGrid::InputDate,
		:parallel_import		=>	HtmlGrid::InputCheckbox,
		:registration_date	=>	HtmlGrid::InputDate,
		:renewal_flag				=>	HtmlGrid::InputCheckbox,
		:revision_date			=>	HtmlGrid::InputDate,
	}
	def init
		reorganize_components()
		super
		error_message()
	end
	def reorganize_components
		if(@model.is_a?(Persistence::CreateItem))
			components.store([1,8], :submit)
			css_map.store([1,8], 'list')
		else
			components.update({
				[0,8]		=>	'fi_upload_instruction0',
				[2,8]		=>	:fachinfo_label,
				[3,8,0]	=>	:fachinfo,
				[3,8,1]	=>	:assign_fachinfo,
				[0,9]		=>	'fi_upload_instruction1',
				[1,9]		=>	:language_select,
				[0,10]	=>	'fi_upload_instruction2',
				[1,10]	=>	:fachinfo_upload,
				[0,11]	=>	'fi_upload_instruction3',
				[1,11]	=>	:submit,
				[1,11,1]=>	:new_registration,
			})
      colspan_map.store([3,8], 3)
			css_map.store([0,8], 'list bg bold')
			css_map.store([1,8], 'list bg')
			css_map.store([2,8,2], 'list')
			css_map.store([0,9,2,3], 'list bg')
		end
	end
	def company_name(model, session=@session)
		klass = if(session.user.is_a?(ODDB::CompanyUser))
			HtmlGrid::Value
		else
			HtmlGrid::InputText
		end
		klass.new(:company_name, model, session, self)
	end
	def complementary_select(model, session=@session)
		HtmlGrid::Select.new(:complementary_type, model, @session, self)
	end
	def iksnr(model, session=@session)
		klass = if(model.is_a?(Persistence::CreateItem) \
			|| model.is_a?(ODDB::IncompleteRegistration))
			HtmlGrid::InputText
		else
			HtmlGrid::Value
		end
		klass.new(:iksnr, model, session, self)
	end
	def indication(model, session=@session)
		InputDescription.new(:indication, model.indication, session, self)
	end
	def new_registration(model, session=@session)
		get_event_button(:new_registration)
	end
	def patented_until(model, session=@session)
		unless (model.is_a? Persistence::CreateItem)
			link = nil
			if((patent = model.patent) && (date = patent.expiry_date))
				link = HtmlGrid::Link.new(:patented_until, patent, @session, self)
				args = {'pointer' => patent.pointer}
				link.href = @lookandfeel._event_url(:resolve, args)
				link.value = @lookandfeel.format_date(date)
			else
				link = HtmlGrid::Link.new(:patented_until, nil, @session, self)
				args = {:pointer => model.pointer}
				link.href = @lookandfeel.event_url(:new_patent, args)
				link.value = @lookandfeel.lookup(:new_patent)
			end
			link.label = true
			link.set_attribute('class', 'list')
			link
		end
	end
end
class ResellerRegistrationForm < View::Form
	include HtmlGrid::ErrorMessage
	include View::AdditionalInformation
	include FachinfoPdfMethods
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:registration_date,
		[0,1]		=>	:company_name,
		[2,1]		=>	:revision_date,
		[0,2]		=>	:indication,
		[2,2]		=>	:inactive_date,
		[0,3]		=>	:fi_upload_instruction0,
		[1,3]		=>	:not_invoiceable,
		[2,3]		=>	:fachinfo_label,
		[3,3,0]	=>	:fachinfo,
	}
	CSS_MAP = {
		[0,0,4,3]	=>	'list',
		[0,3]			=>	'list',
		[1,3]			=>	'list',
		[2,3,2]		=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	SYMBOL_MAP = {
		:expiration_date		=>	HtmlGrid::DateValue,
		:registration_date	=>	HtmlGrid::DateValue,
		:revision_date			=>	HtmlGrid::DateValue,
		:fachinfo_label			=>	HtmlGrid::LabelText,
		:fi_upload_instruction0=>	HtmlGrid::LabelText,
	}
	def init
		reorganize_components
		super
		error_message()
	end
	def reorganize_components
		if(@model.company.invoiceable?)
			components.update({
				[3,3,1]	=>	:assign_fachinfo,
				[0,4]		=>	'fi_upload_instruction1',
				[1,4]		=>	:language_select,
				[0,5]		=>	'fi_upload_instruction2',
				[1,5]		=>	:fachinfo_upload,
				[0,6]		=>	'fi_upload_instruction3',
				[1,6]		=>	:submit,
			})
			components.delete([1,3])
			css_map.update({
				[0,3]			=>	'list bold',
				[1,3]			=>	'list bg',
				[0,4,2,3]	=>	'list bg',
			})
		end
	end
	def not_invoiceable(model, session=@session)
		link = PointerLink.new(:e_company_not_invoiceable, 
													 model.company, @session, self)
		link.label = false
		link
	end
end
class RegistrationComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,1]		=>	View::Admin::RegistrationInnerComposite,
		[0,2]		=>	:registration_sequences,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	SEQUENCES = View::Admin::RegistrationSequences
	def registration_sequences(model, session)
		if(sequences = model.sequences)
			values = PointerArray.new(sequences.values, model.pointer)
			self::class::SEQUENCES.new(values, session, self)
		end
	end
end
class RootRegistrationComposite < View::Admin::RegistrationComposite
	COMPONENTS = {
		[0,1]		=>	View::Admin::RegistrationForm,
		[0,2]		=>	:registration_sequences,
		[0,3]		=>	"th_source",
		[0,4]		=>	:source,
	}
	SEQUENCES = View::Admin::RootRegistrationSequences
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,3]	=>	"subheading",
	}
end
class ResellerRegistrationComposite < View::Admin::RootRegistrationComposite
	COMPONENTS = {
		[0,1]		=>	View::Admin::ResellerRegistrationForm,
		[0,2]		=>	:registration_sequences,
		[0,3]		=>	"th_source",
		[0,4]		=>	:source,
	}
end
class Registration < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::RegistrationComposite
	SNAPBACK_EVENT = :result
end
class RootRegistration < View::Admin::Registration
	CONTENT = View::Admin::RootRegistrationComposite
end
class ResellerRegistration < View::Admin::Registration
	CONTENT = View::Admin::ResellerRegistrationComposite
end
		end
	end
end
