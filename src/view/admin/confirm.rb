#!/usr/bin/env ruby
# View::Admin::Confirm -- ODDB -- 26.01.2005 -- hwyss@ywesee.com

require 'view/publictemplate'

module ODDB
	module View
		module Admin
class ConfirmComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'confirmation',
		[0,1]	=>	:confirm,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'confirm',
	}
	CSS_CLASS = 'composite'
	LEGACY_INTERFACE = false
	def confirm(model)
		@lookandfeel.lookup(model)
	end
end
class Confirm < View::PublicTemplate
	CONTENT = View::Admin::ConfirmComposite
end
		end
	end
end
