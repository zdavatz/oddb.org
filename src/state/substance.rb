#!/usr/bin/env ruby
# SubtanceState -- oddb -- 25.05.2004 -- maege@ywesee.com

require 'state/global'
require 'view/substance'

module ODDB
	class SubstanceState < GlobalState
		VIEW = SubstanceView
		def delete
			if(@model.empty?)
				@session.app.delete(@model.pointer)
				substances() # from RootState
			else
				MergeSubstanceState.new(@session, @model)
			end
		end
		def update
			languages = @session.lookandfeel.languages.dup
			languages << 'en' << 'lt'
			input = languages.inject({}) { |inj, key|
				value = @session.user_input(key.intern)
				puts key, value
				unless [nil, @model].include?(subst = @session.app.substance_by_conn_name(value))
					puts subst
					@errors.store(key.intern, SBSM::ProcessingError.new('e_duplicate_substance', key, value))
				end
				inj.store(key, value)
				inj
			}
			unless error?
				@model = @session.app.update(@model.pointer, input)	
			end
			self
		end
	end
end
