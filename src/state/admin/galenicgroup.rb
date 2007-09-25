#!/usr/bin/env ruby
# State::Admin::GalenicGroup -- oddb -- 26.03.2003 -- andy@jetnet.ch

require 'state/admin/global'
require 'state/admin/galenicgroups'
require 'view/admin/galenicgroup'

module ODDB
	module State
		module Admin
class GalenicGroup < State::Admin::Global
	VIEW = View::Admin::GalenicGroup
	def delete
		begin
			ODBA.transaction {
				@session.app.delete(@model.pointer)
			}
			galenic_groups() # from RootState
		rescue StandardError => e
			State::Exception.new(@session, e)
		end
	end
	def update
    keys = [:route_of_administration].concat @session.lookandfeel.languages
    input = user_input(keys)
		ODBA.transaction {
			@model = @session.app.update(@model.pointer, input, unique_email)
		}
		self
	end
end
		end
	end
end
