#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Feedbacks -- oddb.org -- 13.01.2012 -- mhatakeyama@ywesee.com
# ODDB::State::Feedbacks -- oddb.org -- 25.10.2005 -- ffricker@ywesee.com

require 'state/global_predefine'
require 'util/logfile'
require 'view/rss/feedback'
require 'plugin/plugin'
require 'thread'

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
		@current_feedback or begin
      fb = Persistence::CreateItem.new(Persistence::Pointer.new(:feedback))
      fb.carry(:item, @item)
      @current_feedback = fb
    end
	end
	def feedback_list
    unless @item.feedbacks.is_a?(ODDB::Migel::Item)
      @item.feedbacks[@index, INDEX_STEP]
    end
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
attr_reader :passed_turing_test
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
  unless @passed_turing_test
    mandatory.push :captcha
  end
	keys = mandatory + [:message]
	hash = user_input(keys, mandatory)
  answer = ODDB::LookandfeelBase::DICTIONARIES[@session.language][:captcha_answer]
  if(@passed_turing_test)
    # do nothing
  elsif(hash[:captcha] == answer)
    @passed_turing_test = true
  else
    @errors.store(:captcha, create_error('e_failed_turing_test', 
      :captcha, nil))
  end
	unless(error?)
		feedback = @model.current_feedback
		info_key = :feedback_changed
		if(feedback.is_a?(ODDB::Persistence::CreateItem))
			info_key = :feedback_saved
			hash.each { |key, value|
				feedback.carry(key, value)
			}
      hash.store(:item, @model.item)
		end
		
		# store new Feedback
		time = Time.now
		hash.store(:time , time)
    if msg = hash[:message]
      hash[:message] = msg[0,800]
    end
		@model.current_feedback = @session.app.update(@model.current_feedback.pointer,
                                                  hash)
    @session.update_feedback_rss_feed
		@infos = [info_key]

		# in case this was a new feedback, drop a line into a logfile
		if(info_key == :feedback_saved)
      args = if @model.item.is_a?(ODDB::Package)
               [:reg, @model.item.iksnr, :seq, @model.item.seqnr, :pack, @model.item.ikscd]
             else
               {:pointer => @model.item.pointer}
             end
			link = @session.lookandfeel._event_url(:feedbacks, args)
			line = [ nil, hash[:name], hash[:email], link ].join(';')
			LogFile.append('feedback', line, time)
		end
	end
	self
end
		end
	end
end
