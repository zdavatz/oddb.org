#!/usr/bin/env ruby
# State::User::FiPiOfferInput -- oddb -- 28.06.2004 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/global_predefine'
require 'util/oddbconfig'
require 'view/user/fipi_offer_input'

module ODDB
	module State
		module User
class FiPiOfferInput < State::User::Global
	class FiPiOffer
		attr_accessor :fi_update, :pi_update
		attr_accessor :fi_quantity, :pi_quantity
		def pi_activation_count
			count = 0
			count += 1 unless (@pi_quantity=="" || @pi_quantity=="0")
			count
		end
		def fi_activation_count
			count = 0
			count += 1 unless (@fi_quantity=="" || @fi_quantity=="0")
			count
		end
		def activation_count
			fi_activation_count + pi_activation_count
		end
		def fi_charge
			FI_UPLOAD_PRICES[:annual_fee]
		end
		def fi_update_charge
			if(@fi_update=='update_ywesee')
				FI_UPLOAD_PRICES[:processing]
			end.to_i
		end
		def fi_quantity
			@fi_quantity.to_i
		end
		def pi_charge
			PI_UPLOAD_PRICES[:annual_fee]
		end
		def pi_update_charge
			if(@pi_update=='update_ywesee')
				PI_UPLOAD_PRICES[:processing]
			end.to_i
		end
		def pi_quantity
			@pi_quantity.to_i
		end
		def pi_calculate_activation_charge
			pi_activation_count * PI_UPLOAD_PRICES[:activation]
		end
		def fi_calculate_activation_charge
			fi_activation_count * FI_UPLOAD_PRICES[:activation]
		end
		def calculate_fi_charge
			if(@fi_quantity)
				@fi_quantity.to_i * FI_UPLOAD_PRICES[:annual_fee]
			end.to_i
		end
		def calculate_fi_update
			if(@fi_update=='update_ywesee')
				@fi_quantity.to_i * FI_UPLOAD_PRICES[:processing]
			end.to_i
		end
		def calculate_pi_charge
			if(@pi_quantity)
				@pi_quantity.to_i * PI_UPLOAD_PRICES[:annual_fee]
			end.to_i
		end
		def calculate_pi_update
			if(@pi_update=='update_ywesee')
				@pi_quantity.to_i * PI_UPLOAD_PRICES[:processing]
			end.to_i
		end
		def calculate_total
			calculate_activation_charge = fi_calculate_activation_charge + pi_calculate_activation_charge
			calculate_total_charges + calculate_activation_charge
		end
		def calculate_total_charges
			calculate_fi_charge + calculate_fi_update + \
			calculate_pi_charge + calculate_pi_update
		end
	end
	VIEW = View::User::FiPiOfferInput
	def calculate_offer
		unless(@model.is_a?(FiPiOffer))
			@model = FiPiOffer.new 
		end
		keys = [
			:fi_update,
			:pi_update,
			:fi_quantity,
			:pi_quantity,
		]
		mandatory = []
		input = self.user_input(keys, mandatory)
		quant = input[:fi_quantity].to_i \
			+ input[:pi_quantity].to_i
		keys.each { |key|
			@model.send(key.to_s+"=", input[key])
		}
		if(quant <= 0)
			self
		else
			State::User::FiPiOfferConfirm.new(@session, @model)
		end
	end
end
		end
	end
end
