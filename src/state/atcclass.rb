#!/usr/bin/env ruby
# AtcClassState -- oddb -- 18.07.2003 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'view/atcclass'

module ODDB
	class AtcClassState < GlobalState
		VIEW = AtcClassView
		def init
			super
		end
		def update
			keys = @session.lookandfeel.languages
			input = user_input(keys)
			unless error?
				@model = @session.app.update(@model.pointer, input)
			end
			self
		end
	end
end
