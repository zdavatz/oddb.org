#!/usr/bin/env ruby
# OrphanedPatinfoAssign -- oddb -- 26.11.2003 -- rwaltert@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/list'
require 'htmlgrid/link'
require 'view/additional_information'
require 'view/orphaned_languages'
require 'view/orphaned_patinfo'
require 'view/registration'
require 'view/form'
require 'htmlgrid/inputcheckbox'
require 'view/searchbar'

module ODDB
	class OrphanedPatinfoSequences < FormList
		include RegistrationSequenceList
		include HtmlGrid::ErrorMessage
		#include AdditionalInformation
		COMPONENTS = {
			[0,0]	=>	:checkbox,
			[1,0] =>  :iksnr,
			[2,0]	=>	:seqnr,
			[3,0]	=>	:name_base,
			[4,0]	=>	:name_descr,
			[5,0]	=>	:dose, 
			[6,0]	=>	:galenic_form,
			[7,0]	=>	:patinfo,
		}
		CSS_MAP = {
			[0,0,7]	=>	'list',
			[0,7]	=>	'result-info',
		}
		EVENT = :assign
		SORT_DEFAULT = :name_base
		def init
			super
			error_message()
		end
		def checkbox(model, session)
			name = "pointers[#{@list_index}]" 
			check = HtmlGrid::InputCheckbox.new(name, model, session, self)
			check.value = model.pointer
			check
		end
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
	class OrphanedPatinfoAssignComposite < HtmlGrid::Composite
		include OrphanedLanguages
		COMPONENTS = {
			[0,1] => :languages,
			[0,2] => SearchField,
			[0,3] => :sequences
		}
		CSS_MAP = {
			[0,0] => 'th',
			[0,1] => 'list',
			[0,2] => 'list'
		}
		CSS_CLASS = 'composite'
		DEFAULT_CLASS = HtmlGrid::Value
		DEFAULT_HEAD_CLASS = 'th'
		def sequences(model, session)
			OrphanedPatinfoSequences.new(@model.sequences, session, self)
		end
		def languages(model, session)
			begin 
				super(model.languages, session) 
			rescue NoMethodError => e
				e.message
			end
		end
	end
	class OrphanedPatinfoAssignView < PrivateTemplate
		CONTENT = OrphanedPatinfoAssignComposite
		SNAPBACK_EVENT = :orphaned_patinfos
	end
end
