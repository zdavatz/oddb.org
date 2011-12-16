#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::GalenicForm -- oddb -- 02.03.2011 -- mhatakeyama@ywesee.com 
# State::Admin::GalenicForm -- oddb -- 28.03.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'state/admin/mergegalenicform'
require 'view/admin/galenicform'

module ODDB
	module State
		module Admin
class GalenicGroup < State::Admin::Global; end
class GalenicForm < State::Admin::Global
	VIEW = ODDB::View::Admin::GalenicForm
	def delete
		if(@model.empty?)
			galenic_group = @model.parent(@session.app) 
			@session.app.delete(@model.pointer)
			State::Admin::GalenicGroup.new(@session, galenic_group)
		else
			State::Admin::MergeGalenicForm.new(@session, @model)
		end
	end
	def duplicate?(string)
		!(string.to_s.empty? \
			|| [nil, @model].include?(@session.app.galenic_form(string)))
	end
	def update
		languages = @session.lookandfeel.languages + ['lt']
		input = languages.inject({}) { |inj, key|
			sym = key.intern
			value = @session.user_input(sym)
			if(duplicate?(value))
				@errors.store(sym, 
					create_error('e_duplicate_galenic_form', key, value))
			end
			inj.store(key, value)
			inj
		}
		if(syn_list = @session.user_input(:synonym_list))
			syns = syn_list.split(/\s*,\s*/u)
			syns.each { |syn| 
				if(duplicate?(syn))
					@errors.store(:synonym_list, 
						create_error('e_duplicate_galenic_form', 
							:synonym_list, syn))
				end
			}
			input.store(:synonyms, syns)
		end
    input.store(:galenic_group, @model.parent(@session.app).pointer)
		unless error?
			@model = @session.app.update(@model.pointer, input, unique_email)
		end
		self
	end
end
		end
	end
end
