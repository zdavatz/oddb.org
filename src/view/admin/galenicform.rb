#!/usr/bin/env ruby
# View::Admin::GalenicForm -- oddb -- 25.03.2003 -- andy@jetnet.ch

require 'view/drugs/privatetemplate'
require 'view/admin/registration'
require 'view/descriptionform'
require 'htmlgrid/select'

module ODDB
	module View
		module Admin
class GalenicGroupSelect < HtmlGrid::AbstractSelect
	private
	def selection(context)
		selected = @model.galenic_group.odba_id
		values = @session.app.galenic_groups.values.sort_by { |group| 
			group.description(@lookandfeel.language)
		}
		values.collect { |group| 
			attributes = { "value" => group.pointer.to_s }
			attributes.store("selected", true) if(group.odba_id == selected)
			context.option(attributes) {
				group.description(@lookandfeel.language)
			}
		}
	end
end
class GalenicFormForm < View::DescriptionForm
	COMPONENTS = {
		[2,0]	=>	:galenic_group,
		[2,1]	=>	:sequence_count,
	}
	SYMBOL_MAP = {
		:galenic_group	=>	View::Admin::GalenicGroupSelect,
		:sequence_count =>	HtmlGrid::Value,
	}
	CSS_MAP = {
		[3,1]	=>	'list right'
	}
	def languages
		super + ['lt', 'synonym_list']
	end
end
class GalenicFormComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'galenic_form',
		[0,1]	=>	View::Admin::GalenicFormForm,
    [0,2] =>  :sequences,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
  def sequences(model, session=@session)
    RegistrationSequences.new(model.sequences[0,30], @session, self)
  end
end
class GalenicForm < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::GalenicFormComposite
	SNAPBACK_EVENT = :galenic_groups
end
		end
	end
end
