#!/usr/bin/env ruby
# MergeGalenicFormState -- oddb -- 03.04.2003 -- benfay@ywesee.com

require 'view/mergegalenicform'
require 'state/global_predefine'

module ODDB
	class MergeGalenicFormState < GlobalState
		VIEW = MergeGalenicFormView
		def merge
			galenic_form = @session.user_input(:galenic_form)
			target = @session.app.galenic_form(galenic_form)
			if(target.nil?)
				@errors.store(:galenic_form, create_error('e_unknown_galenic_form', :galenic_form, galenic_form))
				self
			elsif(target == @model)
				@errors.store(:galenic_form, create_error('e_selfmerge_galenic_form', :galenic_form, galenic_form))
				self
			else
				@session.app.merge_galenic_forms(@model, target)
				GalenicFormState.new(@session, target)	
			end
		end
	end
end
