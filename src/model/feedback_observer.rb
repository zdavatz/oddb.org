#!/usr/bin/env ruby
# FeedbackObserver -- oddb -- 09.01.2006 -- hwyss@ywesee.com

module ODDB
	module FeedbackObserver
		attr_reader :feedbacks
		def create_feedback
			feedback = Feedback.new
			feedback.oid = self.feedbacks.keys.max.to_i.next
			## lazy init
			feedbacks.store(feedback.oid, feedback) 
		end
		def feedback(id)
			@feedbacks[id.to_i]
		end
		def feedbacks
			@feedbacks ||= {}
		end
	end
end
