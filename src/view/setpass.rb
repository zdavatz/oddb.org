#!/usr/bin/env ruby
# View::SetPass -- oddb -- 29.09.2005 -- hwyss@ywesee.com

require 'htmlgrid/pass'
require 'htmlgrid/errormessage'
require 'view/privatetemplate'
require 'view/form'

module ODDB
	module View
class SetPassForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:email,
		[0,1]	=>	:set_pass_1,
		[2,1]	=>	:set_pass_2,
		[1,2]	=>	:submit,
	}
	CSS_MAP = {
		[0,0,4,3]	=>	'list',
	}
	LABELS = true
	SYMBOL_MAP = {
		:set_pass_1	=>	HtmlGrid::Pass,
		:set_pass_2	=>	HtmlGrid::Pass,
	}
	def init
		super
		error_message()
	end
end
class SetPassComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'set_pass',
		[0,1]	=>	SetPassForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
end
class SetPass < View::PrivateTemplate
	CONTENT = SetPassComposite
	SNAPBACK_EVENT = :companylist
end
	end
end
