#!/usr/bin/env ruby
# State::Admin::AtcClass -- oddb -- 18.07.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/admin/atcclass'

module ODDB
	module State
		module Admin
class AtcClass < State::Admin::Global
	VIEW = View::Admin::AtcClass
	def init
		super
	end
	def update
		keys = @session.lookandfeel.languages
		input = user_input(keys)
		unless error?
			ODBA.batch {
				@model = @session.app.update(@model.pointer, input)
			}
		end
		self
	end
end
		end
	end
end
