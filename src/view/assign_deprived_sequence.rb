#!/usr/bin/env ruby
#AssignDeprivedSequences -- oddb -- 15.12.2003 -- rwaltert@ywesee.com


require 'view/publictemplate'
require 'htmlgrid/list'
require 'htmlgrid/link'
require 'view/additional_information'
require 'view/orphaned_languages'
require 'view/patinfo_deprived_sequences'
require 'view/registration'
require 'view/form'
require 'htmlgrid/inputradio'
require 'view/searchbar'
require 'view/additional_information'

module ODDB
	class AssignDeprivedSequenceForm < FormList
		include RegistrationSequenceList
		include AdditionalInformation
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
			[0,0,9]	=>	'list',
			[9,0] => 'result-infos',
		}
		COMPONENT_CSS_MAP = {
			[6,0] => 'result-infos',
		}
		SORT_DEFAULT = nil
		def compose_list(model, offset)
			compose_components(model.sequence, offset)
			compose_css(offset)
			offset = resolve_offset(offset, self::class::OFFSET_STEP)
			offset = resolve_offset(offset, self::class::OFFSET_STEP)
			super(model, offset)
		end
		def patinfo_pointer(model, session)
			if(model == @model.sequence)
				link = HtmlGrid::Link.new(:shadow, model, session, self)
				link.href	= @lookandfeel.event_url(:shadow, {:state_id => @session.state.id})
				link.set_attribute('class', 'small')
				link
			else
				patinfo = model.patinfo
				radio = HtmlGrid::InputRadio.new(:patinfo_pointer, patinfo, session, self)
				radio.value = patinfo.pointer
				radio
			end
		end
	end
	class AssignDeprivedSequenceComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0] => :name_base,
			[0,1] => SearchField,
			[0,2] => AssignDeprivedSequenceForm,
			#[0,2]	=>	AssignRegistrationForm,
		}
		CSS_MAP = {
			[0,0] => 'th',
		}
		CSS_CLASS = 'composite'
		DEFAULT_CLASS = HtmlGrid::Value
		DEFAULT_HEAD_CLASS = 'th'
	end
	class SearchField < Form
		COMPONENTS = {
			[0,0] => :search_query,
			[0,0,1]=>:submit
		}
		EVENT = :search_sequences
		FORM_METHOD = 'GET'
		SYMBOL_MAP = {
		 :search_query => SearchBar
		}
	end
	class AssignDeprivedSequenceView < PrivateTemplate
		CONTENT = AssignDeprivedSequenceComposite
		SNAPBACK_EVENT = :patinfo_deprived_sequences
	end
end

