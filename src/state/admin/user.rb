#!/usr/bin/env ruby
# State::Admin::User -- oddb -- 23.07.2003 -- hwyss@ywesee.com 

require 'state/admin/global'

module ODDB
	module State
		module Admin
module User
	VIRAL = true
	RESOLVE_STATES = {}
	def resolve_state(pointer, type=:standard)
		if((type == :standard))
			@viral_module::RESOLVE_STATES.fetch(pointer.skeleton) {
				super
			}
		else
			super
		end
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
	def user_navigation
		[
			State::Admin::Logout,
		]
	end
	private
	def _new_fachinfo(registration)
		doc = FachinfoDocument2001.new
		doc.name = registration.name_base
		fi_pointer = Persistence::Pointer.new(:fachinfo)
		fi = Persistence::CreateItem.new(fi_pointer)
		fi.carry(:name_base, registration.name_base)
		fi.carry(:registrations, [registration])
		fi.carry(@session.language, doc)
		Drugs::RootFachinfo.new(@session, fi)
	end
end
		end
	end
end
