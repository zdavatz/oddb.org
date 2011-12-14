#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::User -- oddb -- 23.07.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'sbsm/viralstate'

module ODDB
	module State
		module Admin
module User
  include SBSM::ViralState
	RESOLVE_STATES = {}
	def resolve_state(pointer, type=:standard)
		if((type == :standard))
			@viral_modules.collect { |mod|
        mod::RESOLVE_STATES[pointer.skeleton]
			}.compact.first || super
		else
			super
		end
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
		fi.carry(:name, registration.name_base)
		fi.carry(:registrations, [registration])
		fi.carry(:company, registration.company)
		fi.carry(@session.language, doc)
		Drugs::RootFachinfo.new(@session, fi)
	end
end
		end
	end
end
