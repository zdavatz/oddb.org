#!/usr/bin/env ruby
# GalenicFormState -- oddb -- 28.03.2003 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'state/mergegalenicform'
require 'view/galenicform'

module ODDB
	class GalenicGroupState < GlobalState; end
	class GalenicFormState < GlobalState
		VIEW = GalenicFormView
		def delete
			if(@model.empty?)
				galenic_group = @model.parent(@session.app) 
				@session.app.delete(@model.pointer)
				GalenicGroupState.new(@session, galenic_group)
			else
				MergeGalenicFormState.new(@session, @model)
			end
		end
		def update
			input = @session.lookandfeel.languages.inject({}) { |inj, key|
				value = @session.user_input(key.intern)
				unless [nil, @model].include?(@session.app.galenic_form(value))
					@errors.store(key.intern, SBSM::ProcessingError.new('e_duplicate_galenic_form', key, value))
				end
				inj.store(key, value)
				inj
			}
			unless error?
				input.store(:galenic_group, @session.user_input(:galenic_group))
				@model = @session.app.update(@model.pointer, input)
			end
			self
		end
	end
end
