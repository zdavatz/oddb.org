#!/usr/bin/env ruby
# Feedbacks -- oddb -- 28.10.2004 -- jlang@ywesee.com, usenguel@ywesee.com

require 'view/feedbacks'
require 'view/publictemplate'
require 'view/additional_information'
require 'view/searchbar'
require 'htmlgrid/form'
require 'htmlgrid/inputradio'
require 'htmlgrid/textarea'
require 'htmlgrid/errormessage'
require 'htmlgrid/infomessage'
require 'htmlgrid/div'

module ODDB
	module View
		module Drugs
class FeedbackForm < View::FeedbackForm
	include HtmlGrid::ErrorMessage
	include HtmlGrid::InfoMessage
	COMPONENTS = {
		[0,0]				=>	:name,
		[0,1]				=>	:email,
		[0,2,0]			=>	:show_email,
		[2,2,1]			=>	'email_text_good',
		[1,3,0]			=>	:show_email_bad,
		[2,3,1]			=>	'email_text_bad',
		[0,5]				=>	:feedback_text_e,
		[0,6,0]			=>	:experience,
		[2,6,1]			=>	'feedback_text_a_good',
		[1,7,0]			=>	:experience_bad,
		[2,7,1]			=>	'feedback_text_a_bad',
		[0,8,0]			=>	:recommend,
		[2,8,1]			=>	'feedback_text_b_good',
		[1,9,0]			=>	:recommend_bad,
		[2,9,1]			=>	'feedback_text_b_bad',
		[0,10,0]			=>	:impression,
		[2,10,1]			=>	'feedback_text_c_good',
		[1,11,0]		=>	:impression_bad,
		[2,11,1]		=>	'feedback_text_c_bad',
		[0,12,0]		=>	:helps,
		[2,12,1]		=>	'feedback_text_d_good',
		[1,13,0]		=>	:helps_bad,
		[2,13,1]		=>	'feedback_text_d_bad',
	}
end
class FeedbackList < View::FeedbackList
	COMPONENTS = {
		[0,0,0]		=>	'feedback_title_name',
		[0,0,1]		=>	:name,
		[0,0,2]		=>	'feedback_title_time',
		[0,0,3]		=>	:time,
		[0,1,0]		=>	:email_label,
		[1,1,1]		=>	:show_email,
		[0,2,0]		=>	:message_label,
		[1,2,1]		=>	:message,
		[0,3,0]		=>	'experience',
		[1,3,1]		=>	:experience,
		[0,4,0]		=>	'recommend',
		[1,4,1]		=>	:recommend,
		[0,5,0]		=>	'impression',
		[1,5,1]		=>	:impression,
		[0,6,0]		=>	'helps',
		[1,6,1]		=>	:helps,
	}
end
class FeedbacksComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[1,0]	  =>	View::SearchForm,
		[0,1]	  =>	:feedback_title,
		[1,1]		=>	:feedback_pager,
		[0,2]	  =>	:current_feedback,
		[1,2]	  =>	:feedback_list,
	}
	CSS_MAP = {
		[0,1] => 'th',
		[1,1] => 'th right',
		[0,2] => 'top',
		[1,2]	=> 'component border-left top'
	}	
	LEGACY_INTERFACE = false
	def current_feedback(model)
		FeedbackForm.new(model.current_feedback, @session, self)
	end
	def feedback_list(model)
		FeedbackList.new(model.feedback_list, @session, self)
	end
	def feedback_pager(model)
		if(model.feedback_count > 0)
			FeedbackPager.new(model, @session, self)
		end
	end
	def feedback_title(model)
		@lookandfeel.lookup(:feedback_title, 
			model.name, model.size)
	end
end
class Feedbacks < View::ResultTemplate
	CONTENT = FeedbacksComposite
end
		end
	end
end
