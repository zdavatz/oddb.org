#!/usr/bin/env ruby
# State::Drugs::GalenicGroup -- oddb -- 26.03.2003 -- andy@jetnet.ch

require 'state/drugs/global'
require 'state/drugs/galenicgroups'
require 'view/drugs/galenicgroup'

module ODDB
	module State
		module Drugs
class GalenicGroup < State::Drugs::Global
	VIEW = View::Drugs::GalenicGroup
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
