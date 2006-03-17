#!/usr/bin/env ruby
# State::Ajax::SwissmedicCat -- oddb.org -- 15.03.2006 -- sfrischknecht@ywesee.com

require 'sbsm/state'
require 'view/ajax/swissmedic_cat'

module ODDB
	module State
		module Ajax
			class SwissmedicCat < SBSM::State
				VOLATILE = true
				VIEW = View::Ajax::SwissmedicCat
				def init
					@model = @session.resolve(@session.user_input(:pointer))
					puts @model.class
					puts @model.name_base
					puts @model.sl_entry
				end
			end
		end
	end
end
