#!/usr/bin/env ruby
# State::Drugs::MergeGalenicForm -- oddb -- 03.04.2003 -- benfay@ywesee.com

require 'state/drugs/global'
require 'view/drugs/mergegalenicform'

module ODDB
	module State
		module Drugs
class MergeGalenicForm < State::Drugs::Global
	VIEW = View::Drugs::MergeGalenicForm
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
			State::Drugs::GalenicForm.new(@session, target)	
		end
	end
end
		end
	end
end
