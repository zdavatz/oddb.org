#!/usr/bin/env ruby
#  -- oddb -- 25.10.2005 -- ffricker@ywesee.com

require 'state/global_predefine'
require 'util/logfile'

module ODDB
	module State
		module Feedbacks
class ItemWrapper < SimpleDelegator
	INDEX_STEP = 10
	attr_writer :current_feedback
	attr_accessor :index
	attr_reader :item
	def initialize(item)
		@item = item
		@index = 0
		super
	end
	def current_feedback
		@current_feedback ||= Persistence::CreateItem.new(@item.pointer + :feedback)
	end
	def feedback_list
		@item.feedbacks.values.sort_by { |feedback|
			feedback.time
		}.reverse[@index, INDEX_STEP]
	end
	def feedback_count
		@item.feedbacks.size
	end
	def has_next?
		feedback_count > next_index
	end
	def has_prev?
		@index > 0
	end
	def next_index
		@index + INDEX_STEP
	end
	def prev_index
		@index - INDEX_STEP
	end
end
def init
	@model = ItemWrapper.new(@model)
	@filter = Proc.new { |model| 
		index = @session.user_input(:index).to_i
		model.index = index
		model
	}
	super
end
def update
	mandatory = [:name, :email, :show_email, :experience, 
		:recommend, :impression, :helps]
	keys = mandatory + [:message]
	hash = user_input(keys, mandatory)
	unless(error?)
		feedback = @model.current_feedback
		info_key = :feedback_changed
		if(feedback.is_a?(ODDB::Persistence::CreateItem))
			info_key = :feedback_saved
			hash.each { |key, value|
				feedback.carry(key, value)
			}
		end
		
		# store new Feedback
		time = Time.now
		hash.store(:time , time)
		@model.current_feedback = @session.app.update(@model.current_feedback.pointer, hash)
		@infos = [info_key]

		# in case this was a new feedback, drop a line into a logfile
		if(info_key == :feedback_saved)
			args = {:pointer => @model.item.pointer}
			link = @session.lookandfeel._event_url(:feedbacks, args)
			line = [
				nil, hash[:name], hash[:email], link
			].join(';')
			LogFile.append('feedback', line, time)
		end
	end
	self
end
		end
	end
end
