#!/usr/bin/env ruby
# OrphanedFachinfoAssign -- oddb -- 11.12.2003 -- rwaltert@ywesee.com

require 'view/orphaned_fachinfo_assign'

module ODDB
	class OrphanedFachinfoAssignState < GlobalState
		VIEW = OrphanedFachinfoAssignView
		class OrphanedFachinfoFacade < SimpleDelegator
			attr_accessor :registrations
			def ancestors(app)
				if(@parent_pointer)
					[@parent_pointer.resolve(app)]
				else
					[]
				end
			end
		end
		def init
			@model = OrphanedFachinfoFacade.new(@model)
			name = @model.name[/^\w+/]
			@model.registrations = named_registrations(name)
		end
		def assign
			if(!@session.error? \
				&& (pointers = @session.user_input(:pointers)) \
				&& !pointers.empty?)
				@session.app.accept_orphaned(model.languages , pointers.values, :fachinfo)
				self
			else
				err = create_error(:e_no_registration_selected, :pointers, nil)
				@errors.store(:pointers, err)
				self
			end
		end
		def delete_orphaned_fachinfo
			puts "delete_orphaned_fachinfo #{@model.pointer}"
			@session.app.delete(@model.pointer)
			puts "done"
			orphaned_fachinfos
		end
		def named_registrations(name)
			if(name.size < 3)
				add_warning(:w_name_to_short,:name, name)
				[]
			else
				sequences = @session.app.sequences_by_name(name.downcase)
				registrations = sequences.collect { |seq|
					seq.registration
				}.uniq
				if(registrations.size > 50)
					add_warning(:w_too_many_sequences, :name, nil)
					[]
				else
					registrations	
				end
			end
		end
		def search_registrations
			name = @session.user_input(:search_query)
			if(name.is_a? String)
				registrations = named_registrations(name)
				@model.registrations = registrations
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
					FachinfoPreviewState.new(@session, doc)
			else
				self
			end
		end
	end
end
