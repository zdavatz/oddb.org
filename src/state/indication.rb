#!/usr/bin/env ruby
# IndicationState -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'state/mergeindication'
require 'view/indication'

module ODDB
	class IndicationState < GlobalState
		VIEW = IndicationView
		def delete
			if(@model.empty?)
				@session.app.delete(@model.pointer)
				indications() # from RootState
			else
				MergeIndicationState.new(@session, @model)
			end
		end
		def update
			input = @session.lookandfeel.languages.inject({}) { |inj, key|
				value = @session.user_input(key.intern)
				unless [nil, @model].include?(@session.app.indication_by_text(value))
					@errors.store(key.intern, SBSM::ProcessingError.new('e_duplicate_indication', key, value))
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
