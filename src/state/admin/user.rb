#!/usr/bin/env ruby
# State::Admin::User -- oddb -- 23.07.2003 -- hwyss@ywesee.com 

require 'state/admin/global'

module ODDB
	module State
		module Admin
module User
	VIRAL = true
	def resolve_state(pointer)
		@viral_module::RESOLVE_STATES.fetch(pointer.skeleton) {
			super
		}
	end
	def trigger(event)
		newstate = super
		unless(event==:logout)
			unless(@viral_module.nil? || newstate.is_a?(@viral_module))
				newstate.extend(@viral_module) 
			end
		end
		newstate
	end
end
		end
	end
end
