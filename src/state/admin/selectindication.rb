#!/usr/bin/env ruby
# State::Admin::SelectSubstance -- oddb -- 23.11.2004 -- hwyss@ywesee.com

require 'view/admin/selectindication'

module ODDB
	module State
		module Admin
class Registration < Global; end
module SelectIndicationMethods
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
		def structural_ancestors(app)
			@registration.structural_ancestors(app)
		end
		def new_indication
			pointer = Persistence::Pointer.new([:indication]) 
			Persistence::CreateItem.new(pointer)
		end
	end
	def update
		pointer = @session.user_input(:pointer)
		indication = pointer.resolve(@session.app)
		if(pointer.skeleton == [:create])
			update = {
				@session.language	=>	@model.user_input[:indication],
			}
			@session.app.update(indication.pointer, update, unique_email)
		end
		if(error?)
			self
		else
			hash = {
				:indication	=>	indication.pointer,
			}
			model = @session.app.update(@model.pointer, hash, unique_email)
			self.class::REGISTRATION_STATE.new(@session, model)
		end
	end
end
class SelectIndication < State::Admin::Global
	VIEW = View::Admin::SelectIndication
	REGISTRATION_STATE = State::Admin::Registration
	include SelectIndicationMethods
end
		end
	end
end
