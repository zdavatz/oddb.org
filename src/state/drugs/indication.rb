#!/usr/bin/env ruby
# State::Drugs::Indication -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'state/drugs/global'
require 'state/drugs/mergeindication'
require 'view/drugs/indication'

module ODDB
	module State
		module Drugs
class Indication < State::Drugs::Global
	VIEW = View::Drugs::Indication
	def delete
		if(@model.empty?)
			@session.app.delete(@model.pointer)
			indications() # from RootState
		else
			State::Drugs::MergeIndication.new(@session, @model)
		end
	end
	def update
		input = @session.lookandfeel.languages.inject({}) { |inj, key|
			value = @session.user_input(key.intern)
			unless [nil, @model].include?(@session.app.indication_by_text(value))
				@errors.store(key.intern, SBSM::ProcessingError.new('e_duplicate_indication', key, value))
			end
			inj.store(key, value)
			inj
		}
		unless error?
			@model = @session.app.update(@model.pointer, input)	
		end
		self
	end
end
		end
	end
end
