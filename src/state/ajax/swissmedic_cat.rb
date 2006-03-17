#!/usr/bin/env ruby
# State::Ajax::SwissmedicCat -- oddb.org -- 15.03.2006 -- sfrischknecht@ywesee.com

require 'state/ajax/global'
require 'view/ajax/swissmedic_cat'

module ODDB
	module State
		module Ajax
class SwissmedicCat < Global
	VIEW = View::Ajax::SwissmedicCat
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
