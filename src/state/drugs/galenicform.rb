#!/usr/bin/env ruby
# State::Drugs::GalenicForm -- oddb -- 28.03.2003 -- hwyss@ywesee.com 

require 'state/drugs/global'
require 'state/drugs/mergegalenicform'
require 'view/drugs/galenicform'

module ODDB
	module State
		module Drugs
class GalenicGroup < State::Drugs::Global; end
class GalenicForm < State::Drugs::Global
	VIEW = View::Drugs::GalenicForm
	def delete
		if(@model.empty?)
			galenic_group = @model.parent(@session.app) 
			@session.app.delete(@model.pointer)
			State::Drugs::GalenicGroup.new(@session, galenic_group)
		else
			State::Drugs::MergeGalenicForm.new(@session, @model)
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
	end
end
