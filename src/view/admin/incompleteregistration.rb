#!/usr/bin/env ruby
# View::Admin::IncompleteRegistration -- oddb -- 19.06.2003 -- hwyss@ywesee.com 

require 'view/drugs/privatetemplate'
require 'view/admin/registration'
require 'htmlgrid/value'
require 'htmlgrid/text'
require 'htmlgrid/button'
require 'htmlgrid/list'
require 'htmlgrid/inputcheckbox'

module ODDB
	module View
		module Admin
class ChangeFlagList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:change_flags,
		[1,0]	=>	:change_flag_descr,
	}
	LEGACY_INTERFACE = false
	OMIT_HEADER = true
	def change_flag_descr(model)
		@lookandfeel.lookup("change_flag_#{model}")
	end
	def change_flags(model)
		box = HtmlGrid::InputCheckbox.new("change_flags[#{model}]", model, 
			@session, self)
	end
end
class ChangeFlags < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:part_1,
		[1,0]	=>	:part_2,
	}
	LEGACY_INTERFACE = false
	def part_1(model)
		change_flags([1,3,4,5,6])
	end
	def part_2(model)
		change_flags([7,8,9,12,14])
	end
	def change_flags(flags)
		list = ChangeFlagList.new(flags, @session, self)
		list.label = true
		list
	end
end
class IncompleteRegistrationForm < View::Admin::RegistrationForm
	include HtmlGrid::ErrorMessage
	DEFAULT_CLASS = HtmlGrid::InputText
	EVENT = :update_incomplete
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:registration_date,
		[0,1]		=>	:company_name,
		[2,1]		=>	:revision_date,
		[0,2]		=>	:generic_type,
		[2,2]		=>	:expiration_date,
		[0,3]		=>	:indication,
		[2,3]		=>	:market_date,
		[2,4]		=>	:inactive_date,
		[1,5]		=>	:submit,
		[1,5,1]	=>	:delete_item,
	}
	def reorganize_components
		if(acceptable?(@model))
			components.store([2,6], :change_flags)
			components.store([1,6], :accept)
			css_map.store([1,6,3], 'list top')
		end
	end
	def acceptable?(model)
		(@session.app.registration(model.iksnr) || model.acceptable?)
	end
	def accept(model, session)
		if(@session.user.allowed?(model))
			button = HtmlGrid::Button.new(:accept, model, session, self)
			button.attributes["onClick"] = 'this.form.event.value="accept";this.form.submit();'
			button
		end
	end
	def change_flags(model, session)
		if(@session.user.allowed?(model))
			box = ChangeFlags.new(model, session, self)
			box.label = true
			box
		end
	end
	def delete_item(model, session)
		if(@session.user.allowed?(model))
			super
		end
	end
end
class IncompleteRegistrationInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:th_source,
		[1,0]	=>	:th_active_registration,
		[0,1]	=>	:source,
		[1,1]	=>	:active_registration,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2]	=>	"subheading",
	}
	SYMBOL_MAP = {
		:th_source	=>	HtmlGrid::Text,
		:th_active_registration	=>	HtmlGrid::Text,
	}
	def active_registration(model, session)
		if(registration = session.app.registration(@model.iksnr))
			_active_registration(registration)
		end
	end
	def _active_registration(registration)
		if(@session.user.allowed?(registration))
			View::Admin::RootRegistrationComposite.new(registration, 
																								 @session, self)
		else
			View::Admin::RegistrationComposite.new(registration, 
																						 @session, self)
		end
	end
end
class IncompleteRegistrationComposite < View::Admin::RootRegistrationComposite
	COMPONENTS = {
		[0,1]	=>	View::Admin::IncompleteRegistrationForm,
		[0,2]	=>	:registration_sequences,
		[0,3]	=>	View::Admin::IncompleteRegistrationInnerComposite,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,3]	=>	'composite',
	}
end
class IncompleteRegistration < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::IncompleteRegistrationComposite
	SNAPBACK_EVENT = :incomplete_registrations
end
		end
	end
end
