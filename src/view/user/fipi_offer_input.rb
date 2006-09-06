#!/usr/bin/env ruby
# View::User::FiPiOfferInput -- oddb -- 28.06.2004 -- mhuggler@ywesee.com

require 'view/resulttemplate'
require 'view/form'
require 'htmlgrid/composite'
require 'htmlgrid/errormessage'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/inputradio'
require 'htmlgrid/link'
require 'htmlgrid/richtext'
require 'htmlgrid/errormessage'
require 'view/centeredsearchform'

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
			price = FI_UPLOAD_PRICES[:processing]
		when 'pi'
			price = PI_UPLOAD_PRICES[:processing]
		end
		if(model.value=='update_ywesee')
			@lookandfeel.lookup(model.value.intern, price.to_s)
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
		[0,0]		=>	'fi_activation_charge',
		[1,0]		=>	:fi_activation_charge_value,
		[0,1]		=>	:fi_quantity_txt,
		[1,1]		=>	:fi_quantity,
		[1,2]		=>	:fi_update,
		[0,4]		=>	'pi_activation_charge',
		[1,4]		=>	:pi_activation_charge_value,
		[0,5]		=>	:pi_quantity_txt,
		[1,5]		=>	:pi_quantity,
		[1,6]		=>	:pi_update,
		[1,7]		=>	:submit,
	}
	CSS_MAP = {
		[0,0,2,3]	=>	'list bg',
		[0,4,2,3]	=>	'list bg',
		[1,7]			=>	'list',
	}
  COLSPAN_MAP = {
    [0,8] => 2,
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
		price = FI_UPLOAD_PRICES[:annual_fee]
		text << price.to_s
		text << @lookandfeel.lookup(:fi_quantity2)
		text
	end
	def fi_update(model, session)
		fi_upd = 'update_autonomous' # set default
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
		price = PI_UPLOAD_PRICES[:annual_fee]
		text << price.to_s
		text << @lookandfeel.lookup(:pi_quantity2)
		text
	end
	def pi_update(model, session)
		pi_upd = 'update_autonomous' # set default
		pi_upd = model.pi_update if(model.respond_to?(:pi_update))
		radio1 = RadioButton.new('pi_update', 'update_ywesee', pi_upd)
		radio2 = RadioButton.new('pi_update', 'update_autonomous', pi_upd)
		View::User::FiPiRadioButtons.new([ radio1, radio2 ], session)	
	end
	def fi_activation_charge_value(model, session)
		price = FI_UPLOAD_PRICES[:activation]
		@lookandfeel.lookup(:swiss_francs, price.to_s)
	end
	def pi_activation_charge_value(model, session)
		price = PI_UPLOAD_PRICES[:activation]
		@lookandfeel.lookup(:swiss_francs, price.to_s)
	end
end
class FiPiOfferInputComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0,0]	=>	'fipi_offer_input',
		[0,0,1]	=>	:amzv_link,
		[0,0,2]	=>	'comma_separator',
		[0,0,3]	=>	:amzv_article13_link,
		[0,0,4]	=>	'nbsp_and_nbsp',
		[0,0,5]	=>	:amzv_article14_link,
		[0,0,6]	=>	'point',
		[0,1]		=>	:fipi_offer_input_explanation,
		[0,2] =>		:pi_upload_link,
		[0,3] =>		:fi_upload_link,
		[0,4]		=>	View::User::FiPiOfferInputForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'list',
		[0,2]	=>	'list',
		[0,3]	=>	'list',
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
	def pi_upload_link(model, session)
		create_link(:pi_upload_link, 'http://wiki.oddb.org/wiki.php?pagename=ODDB.Pi-Upload')
	end
	def fi_upload_link(model, session)
		create_link(:fi_upload_link, 'http://wiki.oddb.org/wiki.php?pagename=ODDB.Fi-Upload')
	end
	def create_link(text_key, href)
		link = HtmlGrid::Link.new(text_key, @model, @session, self)
		link.href = href
		link.set_attribute('class', 'list')
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
class FiPiOfferInput < View::ResultTemplate
	CONTENT = View::User::FiPiOfferInputComposite
	SNAPBACK_EVENT = :home
end
		end
	end
end
