#!/usr/bin/env ruby
# View::Drugs::IncompleteRegistration -- oddb -- 19.06.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'
require 'view/drugs/registration'
require 'htmlgrid/value'
require 'htmlgrid/text'
require 'htmlgrid/button'

module ODDB
	module View
		module Drugs
class IncompleteRegistrationForm < View::Drugs::RegistrationForm
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
	}
	def reorganize_components
		components.update({
			[1,5]		=>	((acceptable?(@model)) ? :accept : :submit),
			[1,5,1]	=>	:delete_item,
		})
	end
	def acceptable?(model)
		(@session.app.registration(model.iksnr) || model.acceptable?)
	end
	def accept(model, session)
		button = HtmlGrid::Button.new(:accept, model, session, self)
		button.attributes["onClick"] = 'this.form.event.value="accept";this.form.submit();'
		button
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
			View::Drugs::RootRegistrationComposite.new(registration, session, self)
		end
	end
end
class IncompleteRegistrationComposite < View::Drugs::RootRegistrationComposite
	COMPONENTS = {
		[0,1]	=>	View::Drugs::IncompleteRegistrationForm,
		[0,2]	=>	:registration_sequences,
		[0,3]	=>	View::Drugs::IncompleteRegistrationInnerComposite,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,3]	=>	'composite',
	}
end
class IncompleteRegistration < View::PrivateTemplate
	CONTENT = View::Drugs::IncompleteRegistrationComposite
	SNAPBACK_EVENT = :incomplete_registrations
end
		end
	end
end
