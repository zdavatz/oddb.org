#!/usr/bin/env ruby
# FiPiOfferConfirmView -- oddb -- 29.06.2004 -- maege@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/composite'
require 'htmlgrid/datevalue'

module ODDB
	class FiPiCalculations < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	:fipi_activation_charge_count,
			[1,0]	=>	'fipi_activation_charge',
			[2,0]	=>	:fipi_activation_charge_value,
			[0,1]	=>	:fi_quantity,
			[1,1]	=>	:fi_charge,
			[2,1]	=>	:calculate_fi_charge,
			[1,2]	=>	:fi_update,
			[2,2]	=>	:fi_update_value,
			[0,3]	=>	:pi_quantity,
			[1,3]	=>	:pi_charge,
			[2,3]	=>	:calculate_pi_charge,
			[1,4]	=>	:pi_update,
			[2,4]	=>	:pi_update_value,
			[0,5]	=>	:nbsp,	
			[1,6]	=>	'total_activation_fee',
			[2,6]	=>	:fipi_activation_charge_value,
			[1,7]	=>	'total_recurring_charges',
			[2,7]	=>	:calculate_total_charges,
			[1,8]	=>	'total',
			[2,8]	=>	:calculate_total,
		}
		CSS_MAP = {
			[0,0,3,5]	=>	'padding bg',
			[0,5,2,1]	=>	'padding bg',
			[2,5]			=>	'padding bg sum',
			[0,6,3,2]	=>	'padding bg bold',
			[0,7,2,2]	=>	'padding bg bold',	
			[2,7]			=>	'padding bg bold sum',
			[2,8]			=>	'padding bg bold total',
		}
		DEFAULT_CLASS = HtmlGrid::Value
		def calculate_total(model, session)
			prize = model.calculate_total
			@lookandfeel.lookup(:swiss_francs, prize.to_s)
		end
		def calculate_total_charges(model, session)
			prize = model.calculate_total_charges
			@lookandfeel.lookup(:swiss_francs, prize.to_s)
		end
		def fi_charge(model, session)
			@lookandfeel.lookup(:fi_charge, model.fi_charge)
		end
		def calculate_fi_charge(model, session)
			prize = model.calculate_fi_charge
			@lookandfeel.lookup(:swiss_francs, prize.to_s)
		end
		def fi_update(model, session)
			@lookandfeel.lookup(model.fi_update.intern, model.fi_update_charge)
		end
		def fi_update_value(model, session)
			prize = model.calculate_fi_update
			@lookandfeel.lookup(:swiss_francs, prize.to_s)
		end
		def fipi_activation_charge_count(model, session)
			model.activation_charge_count
		end
		def fipi_activation_charge_value(model, session)
			prize = model.calculate_activation_charge
			@lookandfeel.lookup(:swiss_francs, prize.to_s)
		end
		def pi_charge(model, session)
			@lookandfeel.lookup(:pi_charge, model.pi_charge)
		end
		def calculate_pi_charge(model, session)
			prize = model.calculate_pi_charge
			@lookandfeel.lookup(:swiss_francs, prize.to_s)
		end
		def pi_update(model, session)
			@lookandfeel.lookup(model.pi_update.intern, model.pi_update_charge)
		end
		def pi_update_value(model, session)
			prize = model.calculate_pi_update
			@lookandfeel.lookup(:swiss_francs, prize.to_s)
		end
	end
	class FiPiOfferConfirmComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	'fipi_offer_confirm',
			[0,0,1]	=>	:amzv_link,
			[0,0,2]	=>	'comma_separator',
			[0,0,3]	=>	:amzv_article13_link,
			[0,0,4]	=>	'nbsp_and_nbsp',
			[0,0,5]	=>	:amzv_article14_link,
			[0,0,6]	=>	'point',
			[0,1]	=>	'fipi_offer_confirmation',
			[0,3]	=>	FiPiCalculations,
			[0,5]	=>	:fipi_offer_disclaimer,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th',
			[0,1]	=>	'padding',
			[0,5]	=>	'padding',
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
		def fipi_offer_disclaimer(model, session)
			today = Time.now()
			date = today.strftime(@lookandfeel.lookup(:date_format))
			@lookandfeel.lookup(:fipi_offer_disclaimer, date)
		end
	end
	class FiPiOfferConfirmView < PublicTemplate
		CONTENT = FiPiOfferConfirmComposite
	end
end
