#!/usr/bin/env ruby
# View::User::FiPiOfferConfirm -- oddb -- 29.06.2004 -- maege@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/composite'
require 'htmlgrid/datevalue'

module ODDB
	module View
		module User
class FiPiCalculations < HtmlGrid::Composite
	COLSPAN_MAP = {}
	COMPONENTS = {}
	COMPONENTS_FI = {
		[0,0] =>  'fachinfo_column',
		
		[0,1]	=>	:fi_activation_count,
		[1,1]	=>	'fi_activation_charge',
		[2,1]	=>	:fi_activation_charge_value,
		
		[0,2]	=>	:fi_quantity,
		[1,2]	=>	:fi_charge,
		[2,2]	=>	:calculate_fi_charge,
		
		[1,3]	=>	:fi_update,
		[2,3]	=>	:fi_update_value,
	}
		
	COMPONENTS_PI = {
		[0,0] =>  'patinfo_column',	
		
		[0,1]	=>	:pi_activation_count,
		[1,1]	=>	'pi_activation_charge',
		[2,1]	=>	:pi_activation_charge_value,
		
		[0,2]	=>	:pi_quantity,
		[1,2]	=>	:pi_charge,
		[2,2]	=>	:calculate_pi_charge,
		
		[1,3]	=>	:pi_update,
		[2,3]	=>	:pi_update_value,
	}
		
	COMPONENTS_FIPI = {
		[1,1]	=>	'total_activation_fee',
		[2,1]	=>	:fipi_activation_charge_value,
		[1,2]	=>	'total_recurring_charges',
		[2,2]	=>	:calculate_total_charges,
		[1,3]	=>	'total',
		[2,3]	=>	:calculate_total,
	}
	CSS_MAP = { }
	DEFAULT_CLASS = HtmlGrid::Value
	def init
		offset = 0
			if(@model.fi_activation_count > 0)
				components.update(COMPONENTS_FI)
			css_map.update({
				[0,1,3,4] => 'padding bg',
				[0,0]			=> 'padding bg bold sum',
			})
			colspan_map.update({
				[0,0] => 3, 
			})
			offset += 5
		end
		if(@model.pi_activation_count > 0)
			COMPONENTS_PI.each { |key, val|
				newkey = key.dup
				newkey[1] += offset
				components.store(newkey, val)
			}
			css_map.update({
				[0,offset+1,3,3] => 'padding bg',
				[0,offset]		 => 'padding bg bold sum',
			})
			colspan_map.update({
				[0,offset] => 3, 
			})
			offset += 4
		end
		COMPONENTS_FIPI.each { |key, val|
			newkey = key.dup
			newkey[1] += offset
			components.store(newkey, val)
		}
		css = {
			[0,offset,2]				=>	'padding bg',
			[2,offset]					=>	'padding bg sum',
			[0,offset + 1,3,3]	=>	'padding bg bold',
			[2,offset + 2]			=>	'padding bg bold sum',
			[2,offset + 3]			=>	'padding bg bold total',
		}
		css_map.update(css)
		super
	end
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
	def fi_activation_count(model, session)
		model.fi_activation_count
	end
	def pi_activation_count(model, session)
		model.pi_activation_count
	end
	def fipi_activation_charge_value(model, session)
		prize = model.fi_calculate_activation_charge + model.pi_calculate_activation_charge
		@lookandfeel.lookup(:swiss_francs, prize.to_s)
	end
	def fi_activation_charge_value(model, session)
		prize = model.fi_calculate_activation_charge
		@lookandfeel.lookup(:swiss_francs, prize.to_s)
	end
	def pi_activation_charge_value(model, session)
		prize = model.pi_calculate_activation_charge
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
		[0,3]	=>	View::User::FiPiCalculations,
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
class FiPiOfferConfirm < View::PublicTemplate
	CONTENT = View::User::FiPiOfferConfirmComposite
end
		end
	end
end
