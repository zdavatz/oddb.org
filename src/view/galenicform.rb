#!/usr/bin/env ruby
# GalenicFormView -- oddb -- 25.03.2003 -- andy@jetnet.ch

require 'view/privatetemplate'
require 'view/descriptionform'
require 'htmlgrid/select'

module ODDB
	class GalenicGroupSelect < HtmlGrid::AbstractSelect
		private
		def selection(context)
			selected = @model.galenic_group
			values = @session.app.galenic_groups.values.sort_by { |group| 
				group.description(@lookandfeel.language)
			}
			values.collect { |group| 
				attributes = { "value" => group.pointer.to_s }
				attributes.store("selected", true) if(group == selected)
				context.option(attributes) {
					group.description(@lookandfeel.language)
				}
			}
		end
	end
	class GalenicFormForm < DescriptionForm
		COMPONENTS = {
			[2,0]	=>	:galenic_group,
			[2,1]	=>	:sequence_count,
		}
		SYMBOL_MAP = {
			:galenic_group	=>	GalenicGroupSelect,
			:sequence_count =>	HtmlGrid::Value,
		}
		CSS_MAP = {
			[3,1]	=>	'list-r'
		}
	end
	class GalenicFormComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	'galenic_form',
			[0,1]	=>	GalenicFormForm,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th',
		}
	end
	class GalenicFormView < PrivateTemplate
		CONTENT = GalenicFormComposite
		SNAPBACK_EVENT = :galenic_groups
	end
end
