#!/usr/bin/env ruby
# State::Drugs::IncompleteSequence -- oddb -- 20.06.2003 -- hwyss@ywesee.com 

require 'state/drugs/global'
require 'state/drugs/sequence'
require 'view/drugs/incompletesequence'

module ODDB
	module State
		module Drugs
class IncompleteSequence < State::Drugs::Sequence
	VIEW = View::Drugs::IncompleteSequence
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
