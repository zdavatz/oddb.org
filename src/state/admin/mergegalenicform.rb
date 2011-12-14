#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::MergeGalenicForm -- oddb -- 02.03.2011 -- mhatakeyama@ywesee.com
# State::Admin::MergeGalenicForm -- oddb -- 03.04.2003 -- benfay@ywesee.com

require 'state/admin/global'
require 'view/admin/mergegalenicform'

module ODDB
	module State
		module Admin
class MergeGalenicForm < State::Admin::Global
	VIEW = ODDB::View::Admin::MergeGalenicForm
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
			State::Admin::GalenicForm.new(@session, target)	
		end
	end
end
		end
	end
end
