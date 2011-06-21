#!/usr/bin/env ruby
# ODDB::Admin::OrphanedPatinfoAssign -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Admin::OrphanedPatinfoAssign -- oddb -- 26.11.2003 -- rwaltert@ywesee.com

require 'view/admin/orphaned_patinfo_assign'

module ODDB
	module State
		module Admin
class OrphanedPatinfoAssign < State::Admin::Global
	VIEW = View::Admin::OrphanedPatinfoAssign
	class OrphanedPatinfoFacade
		attr_accessor :sequences 
		attr_reader		:languages, :name
		def initialize(languages)
			@languages = languages
			if @languages.respond_to?(:pointer)
				@parent_pointer = @languages.pointer 
			end
			@name = begin
				languages.sort.first.last.name
			rescue StandardError => e
				e.message
			end
		end
		def structural_ancestors(app)
			if(@parent_pointer)
				[@parent_pointer.resolve(app)]
			else
				[]
			end
		end
	end
	def init
		@model = OrphanedPatinfoFacade.new(@model)
		name = @model.name[/^\w+/u]
		@model.sequences = named_sequences(name)
	end
	def assign
		if(!@session.error? \
			&& (pointers = @session.user_input(:pointers)) \
			&& !pointers.empty?)
			@session.app.accept_orphaned(model.languages , pointers.values, :patinfo)
			self
		else
			err = create_error(:e_no_sequence_selected, :pointers, nil)
			@errors.store(:pointers, err)
			self
		end
	end
	def named_sequences(name)
		if(name.size < 3)
			add_warning(:w_name_to_short,:name, name)
			[]
		else
			returnvalue = @session.app.search_sequences(name.downcase)
			if(returnvalue.size > 50)
				add_warning(:w_too_many_sequences, :name, nil)
				[]
			else
				returnvalue
			end
		end
	end
	def search_sequences
		name = @session.user_input(:search_query).to_s
		if(name.is_a? String)
			@model.sequences = named_sequences(name)
		else
			err = create_error(:e_name_to_short, :name, name)
			@errors.store(name, err)
		end
		self
	end
	def symbol
		:name_base
	end
	def preview 
		if(lang = @session.user_input(:language_select))
			doc = @model.languages[lang]
			ODDB::State::Admin::PatinfoPreview.new(@session, doc)
		end
	end
end
		end
	end
end
