#!/usr/bin/env ruby
# View::Admin::AssignFachinfo -- oddb -- 21.02.2006 -- hwyss@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/admin/assign_deprived_sequence'
require 'view/additional_information'
require 'view/form'
require 'view/searchbar'

module ODDB
	module View
		module Admin
class SearchRegistrations < View::Form
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0,0] => :search_query,
		[0,0,1] => :submit,
	}
	EVENT = :search_registrations
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
	 :search_query => View::SearchBar
	}
end
class AssignFachinfoForm < View::FormList
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0]	=>	:fachinfo_pointer,
		[1,0]	=>	:iksnr,
		[2,0]	=>	:name_base,
		[3,0]	=>	:company_name,
		[4,0] =>  :fachinfo,
	}
	CSS_MAP = {
		[0,0,5] => 'list',
	}
	CSS_CLASS = 'composite'
	DEFAULT_HEAD_CLASS = 'subheading'
	LEGACY_INTERFACE = false
	SORT_DEFAULT = nil
	EVENT = :assign
	def compose_list(model, offset)
		_compose(model.registration, offset)
		offset = resolve_offset(offset, self::class::OFFSET_STEP)
		offset = resolve_offset(offset, self::class::OFFSET_STEP)
		super(model, offset)
	end
	def fachinfo_pointer(model, session=@session)
		reg = @model.registration
		if(model == reg || !@session.user.allowed?('edit', model))
			# nothing
		elsif(model.fachinfo == reg.fachinfo)
			@lookandfeel.lookup(:assign_fachinfo_equal)			
		else
			check = HtmlGrid::InputCheckbox.new("pointers[#{@list_index}]", 
				model, session, self)
			check.value = model.pointer
			check
		end
	end
end
class AssignFachinfoComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0] => :name_base,
		[0,1] => View::Admin::SearchRegistrations,
		[0,2] => View::Admin::AssignFachinfoForm,
	}
	CSS_MAP = {
		[0,0] => 'th',
	}
	DEFAULT_CLASS = HtmlGrid::Value
end
class AssignFachinfo < View::Drugs::PrivateTemplate
	CONTENT = AssignFachinfoComposite
end
		end
	end
end
