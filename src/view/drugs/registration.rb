#!/usr/bin/env ruby
# View::Drugs::Registration -- oddb -- 07.03.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'
require 'htmlgrid/errormessage'
require 'htmlgrid/datevalue'
require 'htmlgrid/inputdate'
require 'htmlgrid/select'
require 'htmlgrid/inputfile'
require 'view/pointervalue'
require 'view/additional_information'
require 'view/inputdescription'
require 'view/form'

module ODDB
	module View
		module Drugs
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
	def atc_class(model, session)
		if atc = model.atc_class
			atc.code
		end
	end
end
class RegistrationSequences < HtmlGrid::List
	include View::Drugs::RegistrationSequenceList
end
class RootRegistrationSequences < View::FormList
	include View::Drugs::RegistrationSequenceList
end
class FachinfoLanguageSelect < HtmlGrid::AbstractSelect
	attr_accessor :value
	def selection(context)
		values = @lookandfeel.languages
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
		[2,5]		=>  'fachinfo',
	}
	CSS_MAP = {
		[0,0,4,4]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	SYMBOL_MAP = {
		:expiration_date		=>	HtmlGrid::DateValue,
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
		[0,3]		=>	:indication,
		[2,3]		=>	:market_date,
		[2,4]		=>	:inactive_date,
		[0,4]   =>	:language_select,
		[0,5]		=>	:fachinfo_upload,
		[2,5]		=>	:fachinfo_label,
		[3,5]		=>	:fachinfo,
		[1,6]		=>	:submit,
	}
	COMPONENT_CSS_MAP = {
		[0,0,5,5]	=>	'standard',
	}
	CSS_MAP = {
		[0,0,4,6]	=>	'list',
		#[1,3]			=>	'standard',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	SYMBOL_MAP = {
		#:company_name				=>	HtmlGrid::InputText,
		:expiration_date		=>	HtmlGrid::InputDate,
		:fachinfo_upload		=>	HtmlGrid::InputFile,
		:generic_type				=>	HtmlGrid::Select,
		:inactive_date			=>	HtmlGrid::InputDate,
		:market_date				=>	HtmlGrid::InputDate,
		:registration_date	=>	HtmlGrid::InputDate,
		:revision_date			=>	HtmlGrid::InputDate,
	}
	TAG_METHOD = :multipart_form
	def init
		if(@session.user.is_a?(ODDB::AdminUser) \
			&& !@model.is_a?(Persistence::CreateItem))
			components.store([1,6,1], :new_registration)
			CSS_MAP.store([1,6,1], 'button')
		end
		super
		error_message()
	end
	def company_name(model, session)
		klass = if(model.company_name && \
			model.is_a?(Persistence::CreateItem))
			HtmlGrid::Value
		else
			HtmlGrid::InputText
		end
		klass.new(:company_name, model, session, self)
	end
	def fachinfo_label(model, session)
		HtmlGrid::LabelText.new(:fachinfo, model, session , self)
	end
	def iksnr(model, session)
		klass = if(session.user.is_a?(ODDB::AdminUser) \
			|| model.is_a?(Persistence::CreateItem))
			HtmlGrid::InputText
		else
			HtmlGrid::Value
		end
		klass.new(:iksnr, model, session, self)
	end
	def language_select(model, session)
		name = "language_select"
		select = View::Drugs::FachinfoLanguageSelect.new(name, model, session, self)
		#		select.value = ['de', 'fr'][@list_index]
		select
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
		[0,1]		=>	View::Drugs::RegistrationInnerComposite,
		[0,2]		=>	:registration_sequences,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	SEQUENCES = View::Drugs::RegistrationSequences
	def registration_sequences(model, session)
		if(sequences = model.sequences)
			values = PointerArray.new(sequences.values, model.pointer)
			self::class::SEQUENCES.new(values, session, self)
		end
	end
end
class RootRegistrationComposite < View::Drugs::RegistrationComposite
	COMPONENTS = {
		[0,1]		=>	View::Drugs::RegistrationForm,
		[0,2]		=>	:registration_sequences,
		[0,3]		=>	"th_source",
		[0,4]		=>	:source,
	}
	SEQUENCES = View::Drugs::RootRegistrationSequences
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,3]	=>	"subheading",
	}
end
class Registration < View::PrivateTemplate
	CONTENT = View::Drugs::RegistrationComposite
	SNAPBACK_EVENT = :result
end
class RootRegistration < View::Drugs::Registration
	CONTENT = View::Drugs::RootRegistrationComposite
end
		end
	end
end
