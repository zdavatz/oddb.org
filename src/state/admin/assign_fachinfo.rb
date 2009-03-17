#!/usr/bin/env ruby
# State::Admin::AssignFachinfo -- oddb -- 21.02.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/assign_fachinfo'

module ODDB
	module State
		module Admin
class AssignFachinfo < Global
	VIEW = View::Admin::AssignFachinfo
	class RegistrationFacade
		attr_reader :registration, :registrations
		include Enumerable
		def initialize(reg)
			@registration = reg
			@registrations = []
		end
		def structural_ancestors(app)
			[@registration]
		end
		def each(&block)
			@registrations.each(&block)
		end
		def empty?
			@registrations.empty?
		end
		def name_base
			@registration.name_base
		end
		def pointer
			@registration.pointer
		end
		def registrations=(regs)
			@registrations = regs.reject { |reg| reg == @registration }
		end
	end
	def init
		super
		@model = RegistrationFacade.new(@model)
		if((match = /^[^\s]+/u.match(@model.name_base)) \
			&& match[0].size >= 3)
			@model.registrations = named_registrations(match[0])
		end
	end
	def assign
		keys = [:pointers, :pointer]
		input = user_input(keys, keys)
		pointers = input[:pointers].values
		if(pointers \
			&& pointers.any? { |pointer| 
				!allowed?(pointer.resolve(@session))})
			@errors.store(:pointers, 
				create_error('e_not_allowed', :pointers, nil))
		end
		unless(error?)
			if(fi = @model.registration.fachinfo)
        pointers.each { |pointer|
          @session.app.update(pointer, {:fachinfo => fi.pointer}, unique_email)
        }
			end
		end
		self
	end
	def named_registrations(name)
		if(name.size < 3)
			add_warning(:w_name_to_short,:name, name)
			[]
		else
			seqs = @session.app.search_sequences(name.downcase)
			regs = seqs.collect { |seq| seq.registration }.uniq.select { |reg|
				allowed?(reg)
			}
			if(regs.size > 50)
				add_warning(:w_too_many_registrations, :name, nil)
				regs[0,50]
			else
				regs
			end
		end
	end
	def search_registrations
		name = @session.user_input(:search_query)
		if(name.is_a? String)
			@model.registrations = named_registrations(name)
		else
			err = create_error(:e_name_to_short, :name, name)
			@errors.store(name, err)
		end
		self
	end
end
		end
	end
end
