#!/usr/bin/env ruby
# State::Drugs::SelectSubstance -- oddb -- 23.11.2004 -- hwyss@ywesee.com

require 'view/drugs/selectindication'

module ODDB
	module State
		module Drugs
class SelectIndication < State::Drugs::Global
	class Selection
		attr_reader :user_input, :selection
		attr_accessor :registration
		def initialize(user_input, selection, registration)
			@user_input = user_input
			@selection = selection
			@registration = registration
		end
		def pointer
			@registration.pointer
		end
		def ancestors(app)
			@registration.ancestors(app)
		end
		def new_indication
			pointer = Persistence::Pointer.new([:indication]) 
			Persistence::CreateItem.new(pointer)
		end
	end
	VIEW = View::Drugs::SelectIndication
	def update
		pointer = @session.user_input(:pointer)
		indication = pointer.resolve(@session.app)
		if(pointer.skeleton == [:create])
			update = {
				@session.language	=>	@model.user_input[:indication],
			}
			@session.app.update(indication.pointer, update)
		end
		if (error?)
			self
		else
			hash = {
				:indication	=>	indication.pointer,
			}
			model = @session.app.update(@model.pointer, hash)
			State::Drugs::Registration.new(@session, model)
		end
	end
end
		end
	end
end
