#!/usr/bin/env ruby
# IncompleteSequenceState -- oddb -- 20.06.2003 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'state/sequence'
require 'view/incompletesequence'

module ODDB
	class IncompleteSequenceState < SequenceState
		VIEW = IncompleteSequenceView
		alias :do_update :update
		def update
			result_state = self
			if((reg = @session.app.registration(@model.iksnr)) \
				&& (seq = reg.sequence(@model.seqnr)))
				incomplete = @model
				@model = seq
				result_state = do_update
				@model = incomplete
			end
			result_state
		end
		def update_incomplete
			do_update
		end
	end
end
