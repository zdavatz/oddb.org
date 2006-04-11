#!/usr/bin/env ruby
# State::Ajax::DDDPrice -- oddb.org -- 10.04.2006 -- hwyss@ywesee.com

require 'state/ajax/global'
require 'view/ajax/ddd_price'

module ODDB
	module State
		module Ajax
class DDDPrice < Global
	VIEW = View::Ajax::DDDPrice
	def init
		super
		if((pointer = @session.user_input(:pointer)) \
			 && pointer.is_a?(Persistence::Pointer))
			@model = pointer.resolve(@session.app)
		else
			@model = nil
		end
	end
end
		end
	end
end
