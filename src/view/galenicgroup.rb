#!/usr/bin/env ruby
# GalenicGroupView -- oddb -- 26.03.2003 -- andy@jetnet.ch

require 'view/privatetemplate'
require 'view/descriptionlist'
require 'view/descriptionform'
require 'view/pointervalue'
require 'util/pointerarray'

module ODDB
	class GalenicForms < DescriptionList
		COMPONENTS = {
			[0,0]	=>	:oid,
			[1,0]	=>	:description,
		}
		CSS_MAP = {
			[0,0,2]	=>	'list',
		}
		EVENT = :new_galenic_form
		SYMBOL_MAP = {
			:description	=>	PointerLink,
			:oid					=>	PointerLink,
		}
	end
	class GalenicGroupComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	'galenic_group',
			[0,1]	=>	DescriptionForm,
			[0,2]	=>	:galenic_forms,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th',
		}
		def galenic_forms(model, session)
			forms = if(galforms = model.galenic_forms)
				galforms.values
			else
				[]
			end
			mdl = PointerArray.new(forms, model.pointer)
			GalenicForms.new(mdl, session, self) unless model.is_a?(Persistence::CreateItem)
		end
	end
	class GalenicGroupView < PrivateTemplate
		CONTENT = GalenicGroupComposite
		SNAPBACK_EVENT = :galenic_groups
	end
end
