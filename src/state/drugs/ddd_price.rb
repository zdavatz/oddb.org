#!/usr/bin/env ruby
# State::Drugs::DDDPrice -- oddb.org -- 10.04.2006 -- hwyss@ywesee.com

require 'state/drugs/global'
require 'view/drugs/ddd_price'

module ODDB
	module State
		module Drugs
class DDDPrice < Global
  LIMITED = true
	VIEW = View::Drugs::DDDPrice
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
