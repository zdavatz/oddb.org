#!/usr/bin/env ruby
#OrphanedFachinfoAssign -- oddb -- 11.12.2003 -- rwaltert@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/list'
require 'htmlgrid/link'
require 'view/additional_information'
#require 'view/orphaned_fachinfo_assign'
require 'view/orphaned_languages'
require 'view/registration'
require 'view/form'
require 'htmlgrid/inputcheckbox'
require 'view/searchbar'

module ODDB
	class OrphanedFachinfoRegistrations < FormList
		include HtmlGrid::ErrorMessage
		include AdditionalInformation
		COMPONENTS = {
			[0,0]	=>	:checkbox,
			[1,0] =>  :iksnr,
			[2,0]	=>	:name_base,
			[3,0]	=>	:fachinfo,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0,3]	=>	'list',
			[3,0] => 'result-infos',
		}
		COMPONENT_CSS_MAP = {
			[3,0] => 'result-infos',
		}
		DEFAULT_HEAD_CLASS = 'subheading'
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
	class OrphanedDelete < Form
		COMPONENTS = {
			[0,0] => :delete_orphaned_fachinfo,
			[0,0,1] => :submit
			}
		EVENT = :delete_orphaned_fachinfo
		FORM_METHOD = 'POST'
	end
	class SearchFieldFachinfo < Form
		COMPONENTS = {
			[0,0] => :search_query,
			[0,0,1]=>:submit
		}
		EVENT = :search_registrations
		FORM_METHOD = 'GET'
		SYMBOL_MAP = {
		 :search_query => SearchBar
		}
	end
	class OrphanedFachinfoAssignComposite < HtmlGrid::Composite
		include OrphanedLanguages
		COMPONENTS = {
			[0,1] => :languages,
			[0,2] => OrphanedDelete,
			[0,3] => SearchFieldFachinfo,
			[0,4] => :registrations
		}
		CSS_MAP = {
			[0,0] => 'th',
			[0,3] => 'list',
			[0,4] => 'list'
		}
		CSS_CLASS = 'composite'
		DEFAULT_CLASS = HtmlGrid::Value
		DEFAULT_HEAD_CLASS = 'th'
		def registrations(model, session)
			OrphanedFachinfoRegistrations.new(@model.registrations, session, self)
		end
		def languages(model, session)
			begin 
				super(model.languages, session) 
			rescue StandardError => e
				e.message
			end
		end
	end
	class OrphanedFachinfoAssignView < PrivateTemplate
		CONTENT = OrphanedFachinfoAssignComposite
		SNAPBACK_EVENT = :orphaned_fachinfos
	end
end
