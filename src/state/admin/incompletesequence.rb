#!/usr/bin/env ruby
# State::Admin::IncompleteSequence -- oddb -- 20.06.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'state/admin/sequence'
require 'view/admin/incompletesequence'

module ODDB
	module State
		module Admin
class IncompleteSequence < State::Admin::Sequence
	VIEW = View::Admin::IncompleteSequence
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
	end
end
