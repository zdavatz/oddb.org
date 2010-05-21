#!/usr/bin/env ruby
# FeedbackObserver -- oddb -- 09.01.2006 -- hwyss@ywesee.com

module ODDB
	module FeedbackObserver
		attr_reader :feedbacks
		def feedback(id)
			@feedbacks.find { |fb| fb.oid == id.to_i }
		end
    def add_feedback(feedback)
      unless(@feedbacks.include?(feedback))
        @feedbacks.unshift feedback
        @feedbacks.odba_isolated_store
      end
      feedback
    end
    def remove_feedback(feedback)
      if(@feedbacks.delete(feedback))
        @feedbacks.odba_isolated_store
      end
      feedback
    end
	end
end
