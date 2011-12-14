#!/usr/bin/env ruby
# encoding: utf-8
#  -- oddb -- 25.10.2005 -- ffricker@ywesee.com

require 'view/publictemplate'
require 'view/additional_information'
require 'view/captcha'
require 'view/searchbar'
require 'view/form'
require 'htmlgrid/inputradio'
require 'htmlgrid/textarea'
require 'htmlgrid/errormessage'
require 'htmlgrid/infomessage'
require 'htmlgrid/div'

module ODDB
	module View
class FeedbackForm < Form
	include HtmlGrid::ErrorMessage
	include HtmlGrid::InfoMessage
  include Captcha
	CSS_MAP = {
		[0,0,2,15]		=>	'list top',
		[1,4,1,15]		=>	'radio',
	}
	COLSPAN_MAP = {
		[1,0]	=>	2,
		[1,1]	=>	2,
		[1,5]	=>	2,
		[1,15]	=>	2,
	}
	CSS_CLASS = 'composite top'
	LABELS = true
	EVENT = :update
	LEGACY_INTERFACE = false
	def init
    if(@session.state.passed_turing_test)
      components.update([1,15]=>:submit)
    else
      components.update([0,15]=>:captcha, [1,16]=>:captcha_image, [1,17]=>:submit)
      colspan_map.update([1,16]=>2, [1,17]=>2)
    end
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
		js = "if(this.value.length > 800) { (this.value = this.value.substr(0,800))}"
		input.set_attribute('onKeypress', js)
		input.label = true
		input
	end
	def show_email(model)
		radio_good(:show_email)
	end
	def show_email_bad(model)
		radio_bad(:show_email)
	end
	def radio_bad(bad_key)
		radio = HtmlGrid::InputRadio.new(bad_key, model, @session, self)
		if(model.send(bad_key).eql?(false) \
       || @session.user_input(bad_key).eql?(false))
			radio.set_attribute('checked', true)
		end
		radio.value = '0'
		radio.label = false
		radio
	end
	def radio_good(good_key)
		radio = HtmlGrid::InputRadio.new(good_key, model, @session, self)
		if(model.send(good_key) || @session.user_input(good_key))
			radio.set_attribute('checked', true)
		end
		radio.value = '1'
		radio
	end
end
class FeedbackList < HtmlGrid::List
	COLSPAN_MAP = {
		[0,0]	=>	2,
	}
	CSS_MAP = {
		[0,0,2,7]	=>	'list top',
		[0,3,1,4]	=>	'list bold',
	}
	SYMBOL_MAP = { 
		:email_label					=>	HtmlGrid::LabelText,
		:message_label				=>	HtmlGrid::LabelText,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	OMIT_HEADER = true
	OFFSET_STEP = [0,7]
	BACKGROUND_SUFFIX =	' bg'
  SORT_DEFAULT = nil
	def experience(model, session)
		result(model.experience)
	end
	def show_email(model, session)
		if(model.show_email)
			model.email
		else
			@lookandfeel.lookup(:email_text)
		end
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
	end
end
