#!/usr/bin/env ruby
# View::Admin::OrphanedFachinfoAssign -- oddb -- 11.12.2003 -- rwaltert@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/list'
require 'htmlgrid/link'
require 'view/additional_information'
#require 'view/export'
#require 'view/orphaned_fachinfo_assign'
require 'view/admin/orphaned_languages'
require 'view/admin/registration'
require 'view/form'
require 'htmlgrid/inputcheckbox'
require 'view/searchbar'

module ODDB
	module View
		module Admin
class OrphanedFachinfoRegistrations < View::FormList
	include HtmlGrid::ErrorMessage
	include View::AdditionalInformation
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
class OrphanedDelete < View::Form
	COMPONENTS = {
		[0,0] => :delete_orphaned_fachinfo,
		[0,0,1] => :submit
		}
	EVENT = :delete_orphaned_fachinfo
	FORM_METHOD = 'POST'
end
class SearchFieldFachinfo < View::Form
	COMPONENTS = {
		[0,0] => :search_query,
		[0,0,1]=>:submit
	}
	EVENT = :search_registrations
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
	 :search_query => View::SearchBar
	}
end
class OrphanedFachinfoAssignComposite < HtmlGrid::Composite
	include View::Admin::OrphanedLanguages
	COMPONENTS = {
		[0,1] => :languages,
		[0,2] => View::Admin::OrphanedDelete,
		[0,3] => View::Admin::SearchFieldFachinfo,
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
		View::Admin::OrphanedFachinfoRegistrations.new(@model.registrations, session, self)
	end
	def languages(model, session)
		begin 
			super(model.languages, session) 
		rescue StandardError => e
			e.message
		end
	end
end
class OrphanedFachinfoAssign< View::PrivateTemplate
	CONTENT = View::Admin::OrphanedFachinfoAssignComposite
	SNAPBACK_EVENT = :orphaned_fachinfos
end
		end
	end
end
