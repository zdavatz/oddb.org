#!/usr/bin/env ruby
# State::User::SuggestSequence -- oddb -- 29.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/sequence'
require 'view/user/suggest_sequence'

module ODDB
	module State
		module User
class SuggestSequence < Global
	include State::Admin::SequenceMethods
	VIEW = View::User::SuggestSequence
	def suggest_choose
		if(@model._acceptable? && (ptr = @session.user_input(:pointer)) \
			&& (item = @session.resolve(ptr)))
			add = nil
			#klass = nil
			case item
			when Package
				add = [:package, item.ikscd]
				#klass = State::User::SuggestPackage
			when ActiveAgent
				add = [:active_agent, item.substance.name]
				#klass = State::Admin::IncompleteActiveAgent
			end
			if(add)
				inc = @model.pointer + add
				mdl = @session.app.create(inc)
				mdl.fill_blanks(item)
				mdl.odba_store
				#self #klass.new(@session, mdl)
			end
      self
		end
	end
	def update_incomplete
		mandatory = [:name_base, :galenic_form]
		error_check_and_store(:atc_class, 
													@session.user_input(:code), [:atc_class])
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
