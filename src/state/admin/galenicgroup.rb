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
			ODBA.batch {
				@session.app.delete(@model.pointer)
			}
			galenic_groups() # from RootState
		rescue StandardError => e
			State::Exception.new(@session, e)
		end
	end
	def update
		input = @session.lookandfeel.languages.inject({}) { |inj, key|
			inj.store(key, @session.user_input(key.intern))
			inj
		}
		ODBA.batch {
			@model = @session.app.update(@model.pointer, input)
		}
		self
	end
end
		end
	end
end
