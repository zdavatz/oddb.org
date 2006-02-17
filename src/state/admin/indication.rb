#!/usr/bin/env ruby
# State::Admin::Indication -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'state/admin/mergeindication'
require 'view/admin/indication'

module ODDB
	module State
		module Admin
class Indication < State::Admin::Global
	VIEW = View::Admin::Indication
	def delete
		if(@model.empty?)
			@session.app.delete(@model.pointer)
			indications() # from RootState
		else
			State::Admin::MergeIndication.new(@session, @model)
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
			@model = @session.app.update(@model.pointer, input, unique_email)	
		end
		self
	end
end
		end
	end
end
