#!/usr/bin/env ruby
# Feedbacks -- oddb -- 28.10.2004 -- jlang@ywesee.com, usenguel@ywesee.com

require 'view/publictemplate'
require 'view/additional_information'
require 'htmlgrid/form'
require 'htmlgrid/inputradio'
require 'htmlgrid/textarea'
require 'htmlgrid/errormessage'
require 'htmlgrid/infomessage'
require 'htmlgrid/div'

module ODDB
	module View
		module Drugs
class FeedbackForm < HtmlGrid::Form
	include HtmlGrid::ErrorMessage
	include HtmlGrid::InfoMessage
	COMPONENTS = {
		[0,0]			=>	:name,
		[0,1]			=>	:email,
		[0,2]			=>	:feedback_text_e,
		[0,4,0]		=>	:experience,
		[2,4,1]		=>	'feedback_text_a_good',
		[1,5,0]		=>	:experience_bad,
		[2,5,1]		=>	'feedback_text_a_bad',
		[0,6,0]		=>	:recommend,
		[2,6,1]		=>	'feedback_text_b_good',
		[1,7,0]		=>	:recommend_bad,
		[2,7,1]		=>	'feedback_text_b_bad',
		[0,8,0]		=>	:impression,
		[2,8,1]		=>	'feedback_text_c_good',
		[1,9,0]		=>	:impression_bad,
		[2,9,1]		=>	'feedback_text_c_bad',
		[0,10,0]	=>	:helps,
		[2,10,1]	=>	'feedback_text_d_good',
		[1,11,0]	=>	:helps_bad,
		[2,11,1]  =>	'feedback_text_d_bad',
		[2,13]		=>	:submit,
	}
	CSS_MAP = {
		[0,0,2,14]	=>	'list',
		[1,4,1,8]		=>	'radio',
	}
	COLSPAN_MAP = {
		[1,0]	=>	2,
		[1,1]	=>	2,
		[1,2]	=>	2,
	}
	CSS_CLASS = 'composite top'
	LABELS = true
	EVENT = :update
	LEGACY_INTERFACE = false
	def init
		super
		error_message
		info_message
	end
	def experience(model)
		radio_good(:experience)
	end
	def experience_bad(model)
		radio_bad(:experience)
	end
	def helps(model)
		radio_good(:helps)
	end
	def helps_bad(model)
		radio_bad(:helps)
	end
	def impression(model)
		radio_good(:impression)
	end
	def impression_bad(model)
		radio_bad(:impression)
	end
	def recommend(model)
		radio_good(:recommend)
	end
	def recommend_bad(model)
		radio_bad(:recommend)
	end
	def feedback_text_e(model)
		input = HtmlGrid::Textarea.new(:message, model, @session, self)
		input.set_attribute('cols', 53)
		input.set_attribute('rows', 4)
		input.set_attribute('wrap', true)
		js = "if(this.value.length > 400) { (this.value = this.value.substr(0,400))}" 
		input.set_attribute('onKeypress', js)
		input.label = true
		input
	end
	def radio_bad(bad_key)
		radio = HtmlGrid::InputRadio.new(bad_key, model, @session, self)
		if(model.send(bad_key).eql?(false))
			radio.set_attribute('checked', true)
		end
		radio.value = '0'
		radio.label = false
		radio
	end
	def radio_good(good_key)
		radio = HtmlGrid::InputRadio.new(good_key, model, @session, self)
		if(model.send(good_key))
			radio.set_attribute('checked', true)
		end
		radio.value = '1'
		radio
	end
end
class FeedbackList < HtmlGrid::List
	BACKGROUND_SUFFIX =	' bg'
	COMPONENTS = {
		[0,0]			=>	'feedback_title_name',
		[0,0, 1]	=>	:name,
		[0,0, 2]	=>	'feedback_title_time',
		[0,0, 3]	=>	:time,
		[0,1]			=>	'email_label',
		[1,1,1]		=>	:email,
		[0,2]			=>	:message_label,
		[1,2,1]		=>	:message,
		[0,3]			=>	'experience',
		[1,3, 1]	=>	:experience,
		[0,4,]		=>	'recommend',
		[1,4, 1]	=>	:recommend,
		[0,5]			=>	'impression',
		[1,5, 1]	=>	:impression,
		[0,6]			=>	'helps',
		[1,6, 1]	=>	:helps,
	}
	COLSPAN_MAP = {
		[0,0]	=>	2,
	}
	CSS_MAP = {
		[0,0,2,7]	=>	'list top',
		[0,3,1,4]	=>	'list bold',
	}
	SYMBOL_MAP = { 
		#:feedback_title_name	=>	HtmlGrid::LabelText,
		#:feedback_title_time	=>	HtmlGrid::LabelText,
		:email_label					=>	HtmlGrid::LabelText,
		:message_label				=>	HtmlGrid::LabelText,
	}
	CSS_CLASS = 'component border-left top'
	DEFAULT_CLASS = HtmlGrid::Value
	OMIT_HEADER = true
	OFFSET_STEP = [0,7]
	def experience(model, session)
		result(model.experience)
	end
	def recommend(model, session)
		result(model.recommend)
	end
	def impression(model, session)
		result(model.impression)
	end
	def helps(model, session)
		result(model.helps)
	end
	def result(bool)
		div = HtmlGrid::Div.new(bool, @session, self)
		css = 'square '
		if(bool)
			div.value = '+'
			css << 'plus'
		else
			div.value = '-'
			css << 'minus'
		end
		div.css_class = css
		div
	end

	def time(model, session)
		model.time.strftime(@lookandfeel.lookup(:time_format))
	end
end
class FeedbackPager < HtmlGrid::Composite
	CSS_CLASS = 'component right'
	COMPONENTS = {
		[0,0]		=>  :fb_navigation_prev,
		[1,0]	=>  'page_number0',
		[2,0]	=>  :current_page,
		[3,0]	=>  'page_number1',
		[4,0]	=>  :pages,
		[5,0]	=>  :fb_navigation_next,
	}
	LEGACY_INTERFACE = false
	CSS_MAP = {
		[0,0,6] => 'pager',
	}	
	def create_link(text_key, href)
		link = HtmlGrid::Link.new(text_key, @model, @session, self)
		link.href = href
		link.set_attribute('class', 'fbpager')
		link
	end
	def current_page(model)
		model.index / 10 + 1
	end
	def fb_navigation_prev(model)
		if(model.has_prev?)
			args = {
				:index	=>	model.prev_index
			}
			href = @lookandfeel.event_url(:self, args)
			create_link(:pager_back, href)
		else
			@lookandfeel.lookup(:pager_back)
		end
	end
	def fb_navigation_next(model)
		if(model.has_next?)
			args = {
				:index	=>	model.next_index
			}
			href = @lookandfeel.event_url(:self, args)
			create_link(:pager_fwd, href)
		else
			@lookandfeel.lookup(:pager_fwd)
		end
	end
	def pages(model)
		(model.feedback_count.to_f / model.class::INDEX_STEP.to_f).ceil
	end
end
class FeedbacksComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	  =>	:feedback_title,
		[1,0]		=>	:feedback_pager,
		[0,1]	  =>	:current_feedback,
		[1,1]	  =>	:feedback_list,
	}
	CSS_MAP = {
		[0,0] => 'th',
		[1,0] => 'th right',
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
class Feedbacks < View::PublicTemplate
	CONTENT = View::Drugs::FeedbacksComposite
end
		end
	end
end
