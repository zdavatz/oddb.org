#!/usr/bin/env ruby
# State::Substances::Subtance -- oddb -- 25.05.2004 -- maege@ywesee.com

require 'state/substances/global'
require 'view/substances/substance'

module ODDB
	module State
		module Substances
class Substance < State::Substances::Global
	VIEW = View::Substances::Substance
	def delete
		if(@model.empty?)
			@session.app.delete(@model.pointer)
			substances() # from RootState
		else
			@errors.store(:substance, create_error('e_substance_not_empty', :substance, @model))
			self
		end
	end
	def merge
		substance = @session.user_input(:substance_form)
		target = @session.app.substance(substance)
		if(target.nil? || substance.empty?)
			@errors.store(:substance, create_error('e_unknown_substance', :substance, substance))
			self
		elsif(target == @model)
			@errors.store(:substance, create_error('e_selfmerge_substance', :substance, substance))
			self
		elsif(target.has_connection_key? && target.connection_key != @model.connection_key)
			@errors.store(:substance, create_error('e_different_connection_key', :substance, substance))
			self
		else
			@session.app.merge_substances(@model.pointer, target.pointer)
			State::Substances::Substance.new(@session, target)
		end
	end
def update
		languages = @session.lookandfeel.languages.dup
		languages << 'en' << 'lt'
		input = languages.inject({}) { |inj, key|
			value = @session.user_input(key.intern)
			unless [nil, @model].include?(subst = @session.app.substance(value))
				@errors.store(key.intern, SBSM::ProcessingError.new('e_duplicate_substance_description', key, value)) unless (value=="")
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
