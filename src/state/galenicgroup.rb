#!/usr/bin/env ruby
# GalenicGroupState -- oddb -- 26.03.2003 -- andy@jetnet.ch

require 'state/global_predefine'
require 'state/galenicgroups'
require 'view/galenicgroup'

module ODDB
	class GalenicGroupState < GlobalState
		VIEW = GalenicGroupView
		def delete
			begin
				@session.app.delete(@model.pointer)
				galenic_groups() # from RootState
			rescue StandardError => e
				ExceptionState.new(@session, e)
			end
		end
		def update
			input = @session.lookandfeel.languages.inject({}) { |inj, key|
				inj.store(key, @session.user_input(key.intern))
				inj
			}
			@model = @session.app.update(@model.pointer, input)
			self
		end
	end
end
