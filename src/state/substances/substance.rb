#!/usr/bin/env ruby
# State::Substances::Subtance -- oddb -- 25.05.2004 -- maege@ywesee.com

require 'state/substances/global'
require 'state/substances/selectsubstance'
require 'view/substances/substance'

module ODDB
	module State
		module Substances
class Substance < State::Substances::Global
	VIEW = View::Substances::Substance
	def delete
		if(@model.empty?)
			@session.app.delete(@model.pointer)
			#substances() # from RootState
			new_state = result()
			new_state.model.delete(@model)
			new_state
		else
			@errors.store(:substance, create_error('e_substance_not_empty', :substance, @model))
			self
		end
	end
	def delete_connection_key
		if(key = @session.user_input(:connection_key))
			keys = @model.connection_keys
			keys.delete(key)
			@session.app.update(@model.pointer, keys)
		end
		self
	end
	def merge
		substance = @session.user_input(:substance_form)
		new_state = self
		if(substance.size < 3)
			@errors.store(:substance_form, create_error('e_search_query_short',
				:substance_form, substance))
		else
			substances = @session.app.soundex_substances(substance)
			substances.delete(@model)
			if(substances.empty?)
				@errors.store(:substance, create_error('e_unknown_substance', 
					:substance, substance))
			else
				new_model = SelectSubstance::SubstanceSelection.new(@model, 
					substances)
				new_state = SelectSubstance.new(@session, new_model)
			end
		end
		new_state
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
