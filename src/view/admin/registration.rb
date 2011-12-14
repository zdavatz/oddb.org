#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::Registration -- oddb.org -- 30.08.2011 -- mhatakeyama@ywesee.com 
# ODDB::View::Admin::Registration -- oddb.org -- 07.03.2003 -- hwyss@ywesee.com 

require 'view/drugs/privatetemplate'
require 'htmlgrid/errormessage'
require 'htmlgrid/datevalue'
require 'htmlgrid/inputdate'
require 'htmlgrid/select'
require 'htmlgrid/infomessage'
require 'htmlgrid/inputfile'
require 'htmlgrid/inputcheckbox'
require 'view/pointervalue'
require 'view/additional_information'
require 'view/admin/swissmedic_source'
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
		[3,0]	=>	:galenic_form,
		[4,0]	=>	:atc_class,
		[5,0] =>	:patinfo,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,6]	=>	'list',
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
  def galenic_form(model, session=@session)
    lang = @session.language
    model.compositions.collect { |comp|
      galform = (gf = comp.galenic_form) ? gf.send(lang) : ''
      agents = comp.active_agents.collect { |act|
        substance = (sub = act.substance) ? sub.send(lang) : nil
        [substance, act.dose].compact.join ' '
      }.join ', '
      "#{galform} (#{agents})"
    }.join ' + '
  end
	def seqnr(model, session=@session)
		if(@session.allowed?('edit', model))
			PointerLink.new(:seqnr, model, @session, self)
    else
      evt = @session.state.respond_to?(:suggest_choose) ? :suggest_choose : :show
			link = HtmlGrid::Link.new(:seqnr, model, @session, self)
      smart_link_format = model.pointer.to_csv.gsub(/registration/, 'reg').gsub(/sequence/, 'seq').gsub(/package/, 'pack').split(/,/)
      if evt == :show and smart_link_format.include?('reg')
  			link.href = @lookandfeel.event_url(evt, smart_link_format)
      else 
        old_link_format = {:pointer => model.pointer}
			  link.href = @lookandfeel.event_url(evt, old_link_format)
      end
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
    [0,4]   =>  :index_therapeuticus,
		[2,4]		=>	:inactive_date,
    [0,5]   =>  :ith_swissmedic,
		[2,5]		=>  :fachinfo_label,
    [3,5]   =>  :fachinfo,
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
    if(key = model.generic_type)
      label(HtmlGrid::Text.new(key, model, session, self))
    end
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
	include HtmlGrid::InfoMessage
	include View::AdditionalInformation
	include FachinfoPdfMethods
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:registration_date,
		[0,1]		=>	:company_name,
		[2,1]		=>	:revision_date,
		[0,2]		=>	:generic_type,
		[0,3] 	=>	:keep_generic_type,
		[2,2]		=>	:expiration_date,
		[2,3]		=>	:renewal_flag,
		[0,4,0]	=>	:complementary_select,
		[0,4,1]	=>	:complementary_type,
		[2,4]		=>	:market_date,
		[0,5]		=>	:index_therapeuticus,
		[2,5]		=>	:manual_inactive_date,
		[0,6]		=>	:ith_swissmedic,
		[2,6]		=>	:inactive_date,
		[0,7]		=>	:indication,
		[2,7]		=>	:patented_until,
		[0,8]		=>	:export_flag,
    [2,8]   =>  :ignore_patent,
    [3,8]   =>  :violates_patent,
		[0,9]		=>	:parallel_import,
		[2,9]		=>	:vaccine,

	}
	COMPONENT_CSS_MAP = {
		[1,0,1,8]	=>	'standard',
		[3,0,1,8]	=>	'standard',
	}
	CSS_MAP = {
		[0,0,6,10]	=>	'list',
		[0,9]			=>	'list',
	}
  COLSPAN_MAP = { [3,7] => 3 }
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	SYMBOL_MAP = {
    :activate_fachinfo  =>  HtmlGrid::InputDate,
    :deactivate_fachinfo=>  HtmlGrid::InputDate,
		:expiration_date		=>	HtmlGrid::InputDate,
		:export_flag				=>	HtmlGrid::InputCheckbox,
		:vaccine						=>	HtmlGrid::InputCheckbox,
		:fachinfo_label			=>	HtmlGrid::LabelText,
		:generic_type				=>	HtmlGrid::Select,
		:keep_generic_type	=>	HtmlGrid::InputCheckbox,
    :ignore_patent      =>  HtmlGrid::InputCheckbox,
		:inactive_date			=>	HtmlGrid::DateValue,
		:manual_inactive_date=>	HtmlGrid::InputDate,
		:index_therapeuticus=>	HtmlGrid::InputText,
    :ith_swissmedic     =>  HtmlGrid::InputText,
		:market_date				=>	HtmlGrid::InputDate,
		:parallel_import		=>	HtmlGrid::InputCheckbox,
		:registration_date	=>	HtmlGrid::InputDate,
		:renewal_flag				=>	HtmlGrid::InputCheckbox,
		:revision_date			=>	HtmlGrid::InputDate,
    :textinfo_update    =>  HtmlGrid::InputCheckbox,
	}
	def init
		reorganize_components()
		super
    info_message()
		error_message()
	end
	def reorganize_components
		if(@model.is_a?(Persistence::CreateItem))
			components.store([1,10], :submit)
			css_map.store([1,10], 'list')
		else
      components.update({
        [0,10]		=>	'fi_upload_instruction0',
        [2,10]		=>	:fachinfo_label,
        [3,10,0]	=>	:fachinfo,
        [3,10,1]	=>	:assign_fachinfo,
        [0,11]	=>	'fi_upload_instruction1',
        [1,11]	=>	:language_select,
        [2,11]	=>	:textinfo_update,
        [0,12]	=>	'fi_upload_instruction2',
        [1,12]	=>	:fachinfo_upload,
        [2,12]  =>  :activate_fachinfo,
        [0,13]	=>	'fi_upload_instruction3',
        [1,13,0]=>	:submit,
        [1,13,1]=>	:new_registration,
        [2,13]  =>  :deactivate_fachinfo,
      })
      colspan_map.store([3,10], 3)
      colspan_map.store([0,10], 2)
      css_map.store([0,10], 'list bg bold')
      css_map.store([1,10], 'list bg')
      css_map.store([2,10,2,4], 'list')
      css_map.store([0,11,2,3], 'list bg')
      component_css_map.store [3,12,1,2], 'standard'
    end
	end
	def company_name(model, session=@session)
		klass = if(session.user.allowed?('login', 'org.oddb.CompanyUser'))
			HtmlGrid::Value
		else
			HtmlGrid::InputText
		end
		klass.new(:company_name, model, session, self)
	end
	def complementary_select(model, session=@session)
		HtmlGrid::Select.new(:complementary_type, model, @session, self)
	end
  def _fachinfo(model, css='square infos')
    if(model.has_fachinfo?)
      link = HtmlGrid::Link.new(:square_fachinfo,
          model, @session, self)
      link.href = @lookandfeel._event_url(:fachinfo, {:reg => model.iksnr})
      link.css_class = css
      link.set_attribute('title', @lookandfeel.lookup(:fachinfo))
      link
    end
  end
	def iksnr(model, session=@session)
		klass = if model.is_a?(Persistence::CreateItem)
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
  def violates_patent(model, session=@session)
    if model.ignore_patent? \
      || model.sequences.any? { |seqnr, seq| seq.violates_patent? }
      @lookandfeel.lookup(:violates_patent)
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
  include SwissmedicSource
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
  def source(model, session=@session)
    val = HtmlGrid::Value.new(:source, model, @session, self)
    val.value = registration_source(model) if model
    val
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
