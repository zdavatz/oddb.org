#!/usr/bin/env ruby
# State::User::FiPiOfferInput -- oddb -- 28.06.2004 -- maege@ywesee.com

require 'state/user/global'
require 'view/user/fipi_offer_input'

module ODDB
	class FiPiOfferInputState < GlobalState
		class FiPiOffer
			attr_accessor :fi_update, :pi_update
			attr_accessor :fi_quantity, :pi_quantity
			FIPI_ACTIVATION_CHARGE = 1500
			FI_CHARGE	= 350
			FI_UPDATE = 150
			PI_CHARGE = 120
			PI_UPDATE = 90
			def activation_charge
				FIPI_ACTIVATION_CHARGE
			end
			def activation_charge_count
				count = 0
				count += 1 unless @fi_quantity==""
				count += 1 unless @pi_quantity==""
				count += 1 unless (@fi_quantity=="" || @fi_quantity=="0")
				count += 1 unless (@pi_quantity=="" || @pi_quantity=="0")
				count
			end
			def fi_charge
				FI_CHARGE
			end
			def fi_update_charge
				prize = 0
				prize = FI_UPDATE if @fi_update=='update_ywesee'
				prize
			end
			def fi_quantity
				if(@fi_quantity=="")
					0
				else
					@fi_quantity
				end
			end
			def pi_charge
				PI_CHARGE
			end
			def pi_update_charge
				prize = 0
				prize = PI_UPDATE if @pi_update=='update_ywesee'
				prize
			end
			def pi_quantity
				if(@pi_quantity=="")
					0
				else
					@pi_quantity
				end
			end
			def calculate_activation_charge
				activation_charge_count * FIPI_ACTIVATION_CHARGE
			end
			def calculate_fi_charge
				if(@fi_quantity)
					@fi_quantity.to_i * FI_CHARGE
				else
					0
				end
			end
			def calculate_fi_update
				if(@fi_update=='update_ywesee')
					@fi_quantity.to_i * FI_UPDATE
				else
					0
				end
			end
			def calculate_pi_charge
				if(@pi_quantity)
					@pi_quantity.to_i * PI_CHARGE
				else
					0
				end
			end
			def calculate_pi_update
				if(@pi_update=='update_ywesee')
					@pi_quantity.to_i * PI_UPDATE
				else
					0
				end
			end
			def calculate_total
				calculate_total_charges + calculate_activation_charge
			end
			def calculate_total_charges
				calculate_fi_charge + calculate_fi_update + \
				calculate_pi_charge + calculate_pi_update
			end
		end
		VIEW = FiPiOfferInputView
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
			keys.each { |key|
				@model.send(key.to_s+"=", input[key])
			}
			ODDB::FiPiOfferConfirmState.new(@session, @model)
	module State
		module User
class FiPiOfferInput < State::User::Global
	class FiPiOffer
		attr_accessor :fi_update, :pi_update
		attr_accessor :fi_quantity, :pi_quantity
		FIPI_ACTIVATION_CHARGE = 1500
		FI_CHARGE	= 350
		FI_UPDATE = 150
		PI_CHARGE = 120
		PI_UPDATE = 90
		def activation_charge
			FIPI_ACTIVATION_CHARGE
		end
		def activation_charge_count
			count = 0
			count += 1 unless @fi_quantity==""
			count += 1 unless @pi_quantity==""
			count
		end
		def fi_charge
			FI_CHARGE
		end
		def fi_update_charge
			prize = 0
			prize = FI_UPDATE if @fi_update=='update_ywesee'
			prize
		end
		def fi_quantity
			if(@fi_quantity=="")
				0
			else
				@fi_quantity
			end
		end
		def pi_charge
			PI_CHARGE
		end
		def pi_update_charge
			prize = 0
			prize = PI_UPDATE if @pi_update=='update_ywesee'
			prize
		end
		def pi_quantity
			if(@pi_quantity=="")
				0
			else
				@pi_quantity
			end
		end
		def calculate_activation_charge
			activation_charge_count * FIPI_ACTIVATION_CHARGE
		end
		def calculate_fi_charge
			if(@fi_quantity)
				@fi_quantity.to_i * FI_CHARGE
			else
				0
			end
		end
		def calculate_fi_update
			if(@fi_update=='update_ywesee')
				@fi_quantity.to_i * FI_UPDATE
			else
				0
			end
		end
		def calculate_pi_charge
			if(@pi_quantity)
				@pi_quantity.to_i * PI_CHARGE
			else
				0
			end
		end
		def calculate_pi_update
			if(@pi_update=='update_ywesee')
				@pi_quantity.to_i * PI_UPDATE
			else
				0
			end
		end
		def calculate_total
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
		keys.each { |key|
			@model.send(key.to_s+"=", input[key])
		}
		State::User::FiPiOfferConfirm.new(@session, @model)
	end
end
		end
	end
end
