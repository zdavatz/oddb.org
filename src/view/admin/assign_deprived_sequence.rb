#!/usr/bin/env ruby
# encoding: utf-8
# View::Admin::AssignDeprivedSequences -- oddb -- 15.12.2003 -- rwaltert@ywesee.com


require 'view/drugs/privatetemplate'
require 'htmlgrid/list'
require 'htmlgrid/link'
require 'htmlgrid/inputradio'
require 'view/additional_information'
require 'view/form'
require 'view/searchbar'
require 'view/admin/orphaned_languages'
require 'view/admin/patinfo_deprived_sequences'
require 'view/admin/registration'

module ODDB
	module View
		module Admin
class SearchField < View::Form
	COMPONENTS = {
		[0,0,0] => :search_query,
		[0,0,1] => :submit,
	}
	EVENT = :search_sequences
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
	 :search_query => View::SearchBar
	}
end
class AssignDeprivedSequenceForm < View::FormList
	include View::Admin::RegistrationSequenceList
	include View::AdditionalInformation
	include HtmlGrid::ErrorMessage
	EVENT = :assign_deprived_sequence
	COMPONENTS = {
		[0,0]	=>	:patinfo_pointer,
		[1,0]	=>	:iksnr,
		[2,0]	=>	:seqnr,
		[3,0]	=>	:name_base,
		[4,0]	=>	:name_descr,
		[5,0]	=>	:dose, 
		[6,0]	=>	:galenic_form,
		[7,0]	=>	:company_name,
		[8,0]	=>	:atc_class,
		[9,0] =>  :patinfo,
	}
	CSS_MAP = {
		[0,0]		=>	'small list',
		[1,0,9]	=>	'list',
	}
	SORT_DEFAULT = nil
	def init
		super
		error_message
	end
	def compose_list(model, offset)
		_compose(model.sequence, offset)
		#compose_components(model.sequence, offset)
		#compose_css(offset)
		offset = resolve_offset(offset, self::class::OFFSET_STEP)
		offset = resolve_offset(offset, self::class::OFFSET_STEP)
		super(model, offset)
	end
	def patinfo_pointer(model, session)
		if(model == @model.sequence \
			&& @session.allowed?(:patinfo_shadow))
			link = HtmlGrid::Link.new(:shadow, model, session, self)
			link.href	= @lookandfeel.event_url(:shadow)
			link.set_attribute('class', 'small')
			link
		elsif(patinfo = model.pdf_patinfo)
			radio = HtmlGrid::InputRadio.new(:patinfo_pointer, patinfo, session, self)
			radio.value = model.pointer + [:pdf_patinfo]
			radio
		elsif(patinfo = model.patinfo)
			radio = HtmlGrid::InputRadio.new(:patinfo_pointer, patinfo, session, self)
			radio.value = patinfo.pointer
			radio
		end
	end
end
class AssignDeprivedSequenceComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0] => :name_base,
		[0,1] => View::Admin::SearchField,
		[0,2] => View::Admin::AssignDeprivedSequenceForm,
	}
	CSS_MAP = {
		[0,0] => 'th',
	}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
end
class AssignDeprivedSequence < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::AssignDeprivedSequenceComposite
	SNAPBACK_EVENT = :patinfo_deprived_sequences
end
		end
	end
end
