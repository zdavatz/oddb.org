#!/usr/bin/env ruby
# View::User::FiPiOfferInput -- oddb -- 28.06.2004 -- maege@ywesee.com

require 'view/publictemplate'
require 'view/form'
require 'htmlgrid/composite'
require 'htmlgrid/errormessage'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/inputradio'
require 'htmlgrid/richtext'
require 'htmlgrid/errormessage'

module ODDB
	module View
		module User
class FiPiRadioButtons < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:radio_button,
		[1,0]	=>	:radio_text,
	}
	OFFSET_STEP = [0,1]
	OMIT_HEADER = true
	OMIT_HEAD_TAG = true 
	SORT_HEADER = false 
	SORT_REVERSE = false
	STRIPED_BG = false 
	def radio_text(model, session)
		case model.name[0,2]
		when 'fi'
			prize =  State::User::FiPiOfferInput::FiPiOffer::FI_UPDATE
		when 'pi'
			prize =  State::User::FiPiOfferInput::FiPiOffer::PI_UPDATE
		end
		if(model.value=='update_ywesee')
			@lookandfeel.lookup(model.value.intern, prize.to_s)
		else
			@lookandfeel.lookup(model.value.intern, "0")
		end
	end
	def radio_button(model, session)
		radio = HtmlGrid::InputRadio.new(model.name, model, session)
		radio.value = model.value
		radio.set_attribute('checked', model.checked?)
		radio
	end
end
class FiPiOfferInputForm < View::Form 
	class RadioButton
		attr_reader :name, :value
		attr_accessor :current
		def initialize(name, value, current)
			@name = name
			@value = value
			@current = current
		end
		def checked?
			@value == @current
		end
	end
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,1]		=>	'fi_activation_charge',
		[1,1]		=>	:fi_activation_charge_value,
		[0,2]		=>	:fi_quantity_txt,
		[1,2]		=>	:fi_quantity,
		[1,3]		=>	:fi_update,
		[0,5]		=>	'pi_activation_charge',
		[1,5]		=>	:pi_activation_charge_value,
		[0,6]		=>	:pi_quantity_txt,
		[1,6]		=>	:pi_quantity,
		[1,7]		=>	:pi_update,
		[1,9]		=>	:submit,
	}
	CSS_MAP = {
		[0,0,2,4]	=>	'list bg',
		[0,5,2,4]	=>	'list bg',
		[1,9]			=>	'button left padding',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = false
	SYMBOL_MAP = {
		:fi_quantity	=>	HtmlGrid::InputText,
		:pi_quantity	=>	HtmlGrid::InputText,
	} 
	EVENT = :calculate_offer
	FORM_METHOD = 'POST'
	def fi_quantity_txt(model, session)
		text = HtmlGrid::RichText.new(model, session, self)
		text << @lookandfeel.lookup(:fi_quantity0)
		span = HtmlGrid::Span.new(model, session, self)
		span.value = @lookandfeel.lookup(:fachinfo_column)
		span.css_class = 'bold'
		text << span
		text << @lookandfeel.lookup(:fi_quantity1)
		prize =  State::User::FiPiOfferInput::FiPiOffer::FI_CHARGE
		text << prize.to_s
		text << @lookandfeel.lookup(:fi_quantity2)
		text
	end
	def fi_update(model, session)
		fi_upd = 'update_ywesee'
		fi_upd = model.fi_update if(model.respond_to?(:fi_update))
		radio1 = RadioButton.new('fi_update', 'update_ywesee', fi_upd)
		radio2 = RadioButton.new('fi_update', 'update_autonomous', fi_upd)
		View::User::FiPiRadioButtons.new([ radio1, radio2 ], session)	
	end
	def pi_quantity_txt(model, session)
		text = HtmlGrid::RichText.new(model, session, self)
		text << @lookandfeel.lookup(:pi_quantity0)
		span = HtmlGrid::Span.new(model, session, self)
		span.value = @lookandfeel.lookup(:patinfo_column)
		span.css_class = 'bold'
		text << span
		text << @lookandfeel.lookup(:pi_quantity1)
		prize =  State::User::FiPiOfferInput::FiPiOffer::PI_CHARGE
		text << prize.to_s
		text << @lookandfeel.lookup(:pi_quantity2)
		text
	end
	def pi_update(model, session)
		pi_upd = 'update_ywesee'
		pi_upd = model.pi_update if(model.respond_to?(:pi_update))
		radio1 = RadioButton.new('pi_update', 'update_ywesee', pi_upd)
		radio2 = RadioButton.new('pi_update', 'update_autonomous', pi_upd)
		View::User::FiPiRadioButtons.new([ radio1, radio2 ], session)	
	end
	def fi_activation_charge_value(model, session)
		prize =  State::User::FiPiOfferInput::FiPiOffer::FI_ACTIVATION_CHARGE
		@lookandfeel.lookup(:swiss_francs, prize.to_s)
	end
	def pi_activation_charge_value(model, session)
		prize =  State::User::FiPiOfferInput::FiPiOffer::PI_ACTIVATION_CHARGE
		@lookandfeel.lookup(:swiss_francs, prize.to_s)
	end
end
class FiPiOfferInputComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'fipi_offer_input',
		[0,0,1]	=>	:amzv_link,
		[0,0,2]	=>	'comma_separator',
		[0,0,3]	=>	:amzv_article13_link,
		[0,0,4]	=>	'nbsp_and_nbsp',
		[0,0,5]	=>	:amzv_article14_link,
		[0,0,6]	=>	'point',
		[0,1]		=>	:fipi_offer_input_explanation,
		[0,3]		=>	View::User::FiPiOfferInputForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	def amzv_link(model, session)
		link = HtmlGrid::Link.new(:azmv, model, session, self)
		link.href = @lookandfeel.lookup(:amzv_href)
		link.value = @lookandfeel.lookup(:amzv)
		link.set_attribute('class', 'th')
		link
	end
	def amzv_article13_link(model, session)
		link = HtmlGrid::Link.new(:azmv_article13, model, session, self)
		link.href = @lookandfeel.lookup(:amzv_article13_href)
		link.value = @lookandfeel.lookup(:amzv_article13)
		link.set_attribute('class', 'th')
		link
	end
	def amzv_article14_link(model, session)
		link = HtmlGrid::Link.new(:azmv_article14, model, session, self)
		link.href = @lookandfeel.lookup(:amzv_article14_href)
		link.value = @lookandfeel.lookup(:amzv_article14)
		link.set_attribute('class', 'th')
		link
	end
	def fipi_offer_input_explanation(model, session)
		text = HtmlGrid::RichText.new(model, session, self)
		link = HtmlGrid::Link.new(:ywesee, model, session, self)
		link.href	= @lookandfeel.lookup(:fipi_cost_link)
		link.value = @lookandfeel.lookup(:ywesee)
		link.set_attribute('class', 'list')
		text << @lookandfeel.lookup(:fipi_offer_input_explanation0)
		text << link
		text << @lookandfeel.lookup(:fipi_offer_input_explanation1)
		text
	end
end
class FiPiOfferInput < View::PublicTemplate
	CONTENT = View::User::FiPiOfferInputComposite
	SNAPBACK_EVENT = :home
end
		end
	end
end
