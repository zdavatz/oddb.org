#!/usr/bin/env ruby
# View::Admin::Registration -- oddb -- 07.03.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'
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
		[0,0,6]	=>	'list',
		[6,0]		=> 'result-infos',
	}
	COMPONENT_CSS_MAP = {
		[6,0]			=> 'result-infos',
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
		if(@session.user.allowed?(model))
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
class RegistrationForm < View::Form
	include HtmlGrid::ErrorMessage
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:registration_date,
		[0,1]		=>	:company_name,
		[2,1]		=>	:revision_date,
		[0,2]		=>	:generic_type,
		[2,2]		=>	:expiration_date,
		[0,3]		=>	:complementary_type,
		[2,3]		=>	:market_date,
		[0,4]		=>	:indication,
		[2,4]		=>	:inactive_date,
		[0,5]		=>	:export_flag,
	}
	COMPONENT_CSS_MAP = {
		[0,0,4,5]	=>	'standard',
	}
	CSS_MAP = {
		[0,0,4,10]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	SYMBOL_MAP = {
		:complementary_type	=>	HtmlGrid::Select,
		:expiration_date		=>	HtmlGrid::InputDate,
		:generic_type				=>	HtmlGrid::Select,
		:inactive_date			=>	HtmlGrid::InputDate,
		:market_date				=>	HtmlGrid::InputDate,
		:registration_date	=>	HtmlGrid::InputDate,
		:revision_date			=>	HtmlGrid::InputDate,
		:fachinfo_label			=>	HtmlGrid::LabelText,
		:export_flag				=>	HtmlGrid::InputCheckbox,
	}
	TAG_METHOD = :multipart_form
	def init
		reorganize_components()
		super
		error_message()
	end
	def reorganize_components
		if(@model.is_a?(Persistence::CreateItem))
			components.store([1,6], :submit)
			#css_map.store([1,5], 'button')
		else
			components.update({
				[0,6]		=>	'fi_upload_instruction0',
				[2,6]		=>	:fachinfo_label,
				[3,6]		=>	:fachinfo,
				[3,6,1]	=>	:assign_fachinfo,
				[0,7]		=>	'fi_upload_instruction1',
				[1,7]		=>	:language_select,
				[0,8]		=>	'fi_upload_instruction2',
				[1,8]		=>	:fachinfo_upload,
				[0,9]		=>	'fi_upload_instruction3',
				[1,9]		=>	:submit,
				[1,9,1]	=>	:new_registration,
			})
			#component_css_map.store([0,5,4], 'standard')
			#css_map.store([0,7,4], 'list')
			css_map.store([0,6], 'result-b-r-unknown-left')
			css_map.store([1,6], 'list-bg')
			css_map.store([0,7], 'list-bg')
			css_map.store([1,7], 'list-bg')
			css_map.store([0,8], 'list-bg')
			css_map.store([1,8], 'list-bg')
			#css_map.store([1,6], 'button')
		end
	end
	def assign_fachinfo(model, session)
		link = HtmlGrid::Link.new(:assign_fachinfo, model, session, self)
		link.href = @lookandfeel.event_url(:assign_fachinfo)
		if(@model.fachinfo)
			link.value = @lookandfeel.lookup(:assign_this_fachinfo)
		end
		link.set_attribute('class', 'small')
		link
	end
	def company_name(model, session)
		klass = if(session.user.is_a?(ODDB::CompanyUser))
			HtmlGrid::Value
		else
			HtmlGrid::InputText
		end
		klass.new(:company_name, model, session, self)
	end
	def fachinfo_upload(model, session)
		input = HtmlGrid::InputFile.new(:fachinfo_upload, model, session, self)
		input.label = false
		input
	end
	def iksnr(model, session)
		klass = if(model.is_a?(Persistence::CreateItem) \
			|| model.is_a?(ODDB::IncompleteRegistration))
			HtmlGrid::InputText
		else
			HtmlGrid::Value
		end
		klass.new(:iksnr, model, session, self)
	end
	def language_select(model, session)
		sel = View::Admin::FachinfoLanguageSelect.new(:language_select, model, 
			session, self)
		sel.label = false
		sel
	end
	def indication(model, session)
		InputDescription.new(:indication, model.indication, session, self)
	end
	def new_registration(model, session)
		get_event_button(:new_registration)
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
class Registration < View::PrivateTemplate
	CONTENT = View::Admin::RegistrationComposite
	SNAPBACK_EVENT = :result
end
class RootRegistration < View::Admin::Registration
	CONTENT = View::Admin::RootRegistrationComposite
end
		end
	end
end
