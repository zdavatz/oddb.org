#!/usr/bin/env ruby
# Feedbacks -- oddb -- 28.10.2004 -- jlang@ywesee.com, usenguel@ywesee.com

require 'state/drugs/global'
require 'view/drugs/feedbacks'

module ODDB
	module State
		module Drugs
class Feedbacks < State::Drugs::Global
	VIEW = View::Drugs::Feedbacks
	class PackageWrapper < SimpleDelegator
		INDEX_STEP = 10
		attr_writer :current_feedback
		attr_accessor :index
		def initialize(package)
			@package = package
			@index = 0
			super
		end
		def current_feedback
			@current_feedback ||= Persistence::CreateItem.new(@package.pointer + :feedback)
		end
		def feedback_list
			@package.feedbacks.values.sort_by { |feedback|
				feedback.time
			}.reverse[@index, INDEX_STEP]
		end
		def feedback_count
			@package.feedbacks.size
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
		@model = PackageWrapper.new(@model)
		@filter = Proc.new { |model| 
			index = @session.user_input(:index).to_i
			model.index = index
			model
		}
		super
	end
	def update
		mandatory = [:name, :email, :experience, 
			:recommend, :impression, :helps]
		keys = mandatory + [:message]
		hash = user_input(keys, mandatory)
		puts hash.inspect
		feedback = @model.current_feedback
		info_key = :feedback_changed
		if(feedback.is_a?(ODDB::Persistence::CreateItem))
			info_key = :feedback_saved
			hash.each { |key, value|
				feedback.carry(key, value)
			}
		end
		unless(error?)
			# store new Feedback
			time = Time.new
			hash.store(:time , time)
			@model.current_feedback = @session.app.update(
				@model.current_feedback.pointer, hash)
			@infos = [info_key]
		else
			puts @errors.inspect
		end
		self
	end
end
		end
	end
end
