#!/usr/bin/env ruby
# State::Substances::Subtance -- oddb -- 25.05.2004 -- mhuggler@ywesee.com

require 'state/substances/global'
require 'state/substances/selectsubstance'
require 'view/substances/substance'

module ODDB
	module State
		module Substances
class Substance < State::Substances::Global
	VIEW = View::Substances::Substance
	def assign
		substance_name = @session.user_input(:effective_form)
		if(substance = @session.substance(substance_name))
			args = {
				:effective_form	=>	substance.pointer,
			}
			@session.app.update(@model.pointer, args, unique_email)
		end
		self
	end
	def delete
		if(@model.empty?)
			ODBA.transaction {
				@session.app.delete(@model.pointer)
			}
			#substances() # from RootState
			new_state = result()
      mdl = new_state.model
			mdl.delete(@model) if(mdl.is_a?(Array))
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
			@session.app.update(@model.pointer, keys, unique_email)
		end
		self
	end
	def duplicate?(string)
		!(string.to_s.empty? \
			|| [nil, @model].include?(@session.app.substance(string)))
	end
	def merge
		substance = @session.user_input(:substance_form)
		new_state = self
		if(substance.size < 3)
			@errors.store(:substance_form, create_error('e_search_query_short',
				:substance_form, substance))
		else
			substances = @session.app.search_substances(substance)
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
		languages = @session.lookandfeel.languages + ['lt']
		input = languages.inject({}) { |inj, key|
			sym = key.intern
			value = @session.user_input(sym)
			if(duplicate?(value))
				@errors.store(sym, 
					create_error('e_duplicate_substance_description', key, value))
			end
			inj.store(key, value)
			inj
		}
		if(syn_list = @session.user_input(:synonym_list))
			syns = syn_list.split(/\s*,\s*/)
			syns.each { |syn| 
				if(duplicate?(syn))
					@errors.store(:synonym_list, 
						create_error('e_duplicate_substance_description', 
							:synonym_list, syn))
				end
			}
			input.store(:synonyms, syns)
		end
		unless error?
			ODBA.transaction {
				@model = @session.app.update(@model.pointer, input, unique_email)	
			}
		end
		self
	end
end
		end
	end
end
