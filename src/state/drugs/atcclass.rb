#!/usr/bin/env ruby
# State::Drugs::AtcClass -- oddb -- 18.07.2003 -- hwyss@ywesee.com 

require 'state/drugs/global'
require 'view/drugs/atcclass'

module ODDB
	module State
		module Drugs
class AtcClass < State::Drugs::Global
	VIEW = View::Drugs::AtcClass
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
