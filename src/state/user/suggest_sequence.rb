#!/usr/bin/env ruby
# State::User::SuggestSequence -- oddb -- 29.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/sequence'
require 'view/admin/incompletesequence'

module ODDB
	module State
		module User
class SuggestSequence < Global
	include State::Admin::SequenceMethods
	VIEW = View::Admin::IncompleteSequence
	def update_incomplete
		mandatory = [:name_base, :galenic_form, :atc_class]
		input = user_input(mandatory, mandatory)
		newstate = update
		if((reg = @session.app.registration(@model.iksnr)) \
			&& (seq = reg.sequence(@model.seqnr)))
			filled = @model.fill_blanks(seq)
			@model.odba_store unless(filled.empty?)
			filled.each { |key| @errors.delete(key) }
		end
		newstate
	end
end
		end
	end
end
